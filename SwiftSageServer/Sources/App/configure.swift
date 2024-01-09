import Vapor
import WebSocketKit
import func Darwin.fflush
import var Darwin.stdout

// SwiftSageServer

// Run with `./run.sh` in the LogicSage directory.

var SWIFTSAGE_USERNAME:String {
    get {
        keyForName(name: "SWIFTSAGE_USERNAME")
    }
}
var SWIFTSAGE_SERVER_USERNAME:String {
    get {
        keyForName(name: "SWIFTSAGE_SERVER_USERNAME")
    }
}
var SWIFTSAGE_SERVER_PASSWORD:String {
    get {
        keyForName(name: "SWIFTSAGE_SERVER_PASSWORD")
    }
}
var SWIFTSAGE_PASSWORD:String {
    get {
        keyForName(name: "SWIFTSAGE_PASSWORD")
    }
}

func keyForName(name: String) -> String {
    guard let apiKey = plistHelper.objectFor(key: name, plist: "GPT-Info") as? String else { return "" }
    return apiKey
}

let debugging = false

let specs  = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "▇", "▆", "▅", "▄", "▃", "▂", "▁"] +
["░", "▒", "▓", "█","░", "▒","▓", "█","░", "▒","░", "▒", "▓", "█","░"] + ["."]

var clients: [String: [WebSocket]] = [:]
let logoAscii5 = """
LogicSage for Mac Vapor server starting...
"""

let connectedClientsQueue = DispatchQueue(label: "connectedClients.queue")
let clientsQueue = DispatchQueue(label: "clients.queue")

// configures your application
public func configure(_ app: Application) throws {

    var connectedClients: [WebSocket] = []

    app.http.server.configuration.hostname = "0.0.0.0"

    print(logoAscii5)

    app.webSocket("ws") { req, ws in
        var username: String?

        if debugging {
            print("Client connected")
        }

        connectedClientsQueue.async {
            connectedClients.append(ws)
        }
        // BEGIN onText
        ws.onText { ws, text in

            // IF ALREADY AUTHED....
            if let user = username {
                do {
                    if debugging {
                        print("Received MSG from \(user): \(text)")
                    }
                    let json = try JSONSerialization.jsonObject(with: Data(text.utf8), options: .allowFragments) as? [String: String]
                    if debugging {
                        print("parsed to JSON =  \(json)")
                    }
// START HANDLE MESSAGES **********************************************************************************************************************************
                    if let recipient = json?["recipient"] as? String,
                       let message = json?["message"] as? String {

                        if message != "." {
                            print("\(message)")
                        }

                        let senderSettings = userSettings[user] ?? freshConfig()
                        let recipientSettings = userSettings[recipient] ?? freshConfig()

                        let fromUser = json?["from"] as? String
                        if debugging {
                            print("FROM: \(fromUser)")
                        }
                        if debugging {

                            print("Received message from \(user) or fromUser:\(fromUser) to \(recipient): \(message)") //using sender settings: \(senderSettings) and recipient settings: \(recipientSettings)")
                        }
                        // Send the message only to the intended recipient
                        let resps = clients[recipient] ?? []
                        if debugging {
                            print("auth resps = \(resps)")
                        }

                        resps.forEach { recipientSocket in
                            if debugging {
                                print("Received MESSAGE from \(user) or fromUser:\(fromUser) to \(recipient): ws\(recipientSocket)command:\(message)")// using sender settings: \(senderSettings) and recipient settings: \(recipientSettings)")
                            }
                            let logData: [String: String] = ["recipient": recipient, "message": message]
                            do {
                                let logJSON = try JSONSerialization.data(withJSONObject: logData, options: [.fragmentsAllowed])
                                let logString = String(data: logJSON, encoding: .utf8)

                                recipientSocket.send(logString ?? "")
                                if debugging {
                                    print("Sent auth cmd from server to Swift binary.")
                                }
                            }
                            catch {
                                print("error writing auth cmd")
                            }
                        }
                    }
// END HANDLE MESSAGES **********************************************************************************************************************************

// START HANDLE COMMANDS ********************************************************************************************************************************
                    else if let recipient = json?["recipient"] as? String,
                            let command = json?["command"] as? String {
                        print("\(command)")

                        let senderSettings = userSettings[user] ?? freshConfig()
                        let recipientSettings = userSettings[recipient] ?? freshConfig()


                        let fromUser = json?["from"] as? String
                        if debugging {
                            print("FROM: \(fromUser)")
                        }
                        let resps = clients[recipient] ?? []
                        if debugging {
                            print("cmd resps = \(resps)")
                        }

                        resps.forEach { recipientSocket in
                            if debugging {
                                print("Received COMMAND from \(user) or fromUser:\(fromUser) to \(recipient): ws\(recipientSocket)command:\(command) using sender settings: \(senderSettings) and recipient settings: \(recipientSettings)")
                            }
                            let logData: [String: String] = ["recipient": recipient, "command": command]
                            do {
                                let logJSON = try JSONSerialization.data(withJSONObject: logData, options: [.fragmentsAllowed])
                                let logString = String(data: logJSON, encoding: .utf8)
                                recipientSocket.send(logString ?? "")
                                if debugging {
                                    print("Sent auth cmd from server to Swift binary.")
                                }
                            }
                            catch {
                                print("error writing auth cmd")
                            }
                        }
                    } else {
                        ws.send("Invalid command format")
                    }
                }
                catch {
                    print("error = \(error)")
                }
            }
// END HANDLE COMMANDS ********************************************************************************************************************************

// START HANDLE AUTH IF NOT ALREADY AUTHED ********************************************************************************************************************************
            else {
                if debugging {
                    print("No auth for this req, attempting to auth...")
                }
                // Try to parse the received text as JSON
                do {
                    let json = try JSONSerialization.jsonObject(with: Data(text.utf8), options: [.allowFragments]) as? [String: String]

                    if debugging {

                        print("Got JSON = \(json)")
                    }
                    // Validate username and password
                    if let user = json?["username"],  let password = json?["password"],
                       (user == SWIFTSAGE_USERNAME && password == SWIFTSAGE_PASSWORD)
                        ||
                        (user == SWIFTSAGE_SERVER_USERNAME && password == SWIFTSAGE_SERVER_PASSWORD) {
                        clientsQueue.async {
                            // Authenticate the user
                            username = user
                            if clients[user] == nil {
                                clients[user] = []
                            }
                            clients[user]?.append(ws)
                            if debugging {
                                print("Authentication of \(user):\(ws) succeeded")
                            }

                            let resps = clients[SWIFTSAGE_SERVER_USERNAME] ?? []
                            if debugging {
                                print("auth resps = \(resps)")
                            }
                            resps.forEach { recipientSocket in
                                if debugging {
                                    print("Received message fpr recipientSocket = \(recipientSocket)")
                                }
                                // send server auth cmd
                                let logData: [String: String] = ["recipient": SWIFTSAGE_SERVER_USERNAME, "message": "\(logoAscii5)"]
                                do {
                                    let logJSON = try JSONSerialization.data(withJSONObject: logData, options: [.fragmentsAllowed])
                                    let logString = String(data: logJSON, encoding: .utf8)
                                    ws.send(logString ?? "")

                                    recipientSocket.send(logString ?? "")
                                    if debugging {
                                        print("Sent auth cmd from server to Swift binary.")
                                    }
                                }
                                catch {
                                    print("error writing auth cmd")
                                }
                            }
                        }
                    }
                    else {
                        print("Invalid username or password)")
                    }
                } catch {
                    print("Invalid JSON)")
                }
            }
            fflush(stdout)
        }
        // END onText

// END HANDLE AUTH ********************************************************************************************************************************
// START BINARY DATA HANDLING ********************************************************************************************************************************
        ws.onBinary { ws, data in
            if debugging {

                print("Received binary data: \(data)")
            }
            for client in connectedClients {

                guard client !== ws else {
                    if debugging {
                        print("skipping self")
                    }
                    continue
                }
                if debugging {

                    print("send BINARY to client =\(client)")
                }
                client.send(data)
            }
        }
// END BINARY DATA HANDLING ********************************************************************************************************************************

        ws.onClose.whenComplete { result in
            if true {
                if let user = username {
                    clientsQueue.async {
                        clients[user]?.removeAll(where: { $0 === ws })
                        if clients[user]?.isEmpty ?? false {
                            clients.removeValue(forKey: user)
                        }
                        if debugging {
                            print("Client disconnected: \(user)")
                        }
                    }
                }
            }
        }
    }
    advertise()
}

func advertise() {
    // Start advertising the WebSocket server using Bonjour
    let serviceName = "SwiftSageServer"
    let serviceType = "_sagess._tcp"
    let servicePort = 8080

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["dns-sd", "-R", serviceName, serviceType, ".", String(servicePort)]
    do {
        try process.run()
    }
    catch {
        print("caught an advertising error = \(error)")
    }
}

// TODO: Actually implement server side settings.
var userSettings: [String: Config] = [:]

let builtInAppDesc = "a simple SwiftUI app that shows SFSymbols and Emojis that go together well on a scrollable grid"

enum InputMode {
    case loading
    case normal
    case debate
    case trivia
}
struct TriviaQuestion {
    let question: String
    let code: String?
    let options: [String]
    let correctOptionIndex: Int
    let reference: String
}

func freshConfig() -> Config {
    Config(
        projectName: "MyApp",
        globalErrors: [String](),
        manualPromptString: "",
        blockingInput: false,
        promptingRetryNumber: 0,
        lastFileContents: [String](),
        lastNameContents: [String](),
        searchResultHeadingGlobal: nil,
        appName: "MyApp",
        appType: "iOS",
        appDesc: builtInAppDesc,
        language: "Swift",
        conversational: false,
        streak: 0,
        chosenTQ: nil,
        promptMode: .normal,
        // EXPERIMENTAL: YE BEEN WARNED!!!!!!!!!!!!
        enableGoogle: false,
        enableLink: false,
        loadMode: LoadMode.dots
    )
}

struct Config {
    var projectName: String
    var globalErrors: [String]
    var manualPromptString: String
    var blockingInput: Bool
    var promptingRetryNumber: Int

    var lastFileContents: [String]
    var lastNameContents: [String]
    var searchResultHeadingGlobal: String?
    var linkResultGlobal: String?

    var appName: String
    var appType: String

    var appDesc: String
    var language: String

    var conversational: Bool
    var streak: Int
    var chosenTQ: TriviaQuestion?
    var promptMode: InputMode

    // EXPERIMENTAL: YE BEEN WARNED!!!!!!!!!!!!
    var enableGoogle: Bool
    var enableLink: Bool

    var loadMode: LoadMode
}

enum LoadMode {
    case none
    case dots
    case bar
    case waves
    case matrix
}
