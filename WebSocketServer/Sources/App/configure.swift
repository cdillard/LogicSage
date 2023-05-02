import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import WebSocketKit
import func Darwin.fflush
import var Darwin.stdout

let debugging = true

let specs  = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "▇", "▆", "▅", "▄", "▃", "▂", "▁"] + 
             ["░", "▒", "▓", "█","░", "▒","▓", "█","░", "▒","░", "▒", "▓", "█","░"] + ["."]
    
var clients: [String: [WebSocket]] = [:]

// configures your application
public func configure(_ app: Application) throws {

    var connectedClients: [WebSocket] = []

    app.http.server.configuration.hostname = "0.0.0.0"

    app.webSocket("ws") { req, ws in
        var username: String?

        if debugging {
            print("Client connected")
        }
        
        connectedClients.append(ws)

        ws.onText { ws, text in

            if true {
                if let user = username {
                    do {
                        print("Received MSG from \(user): \(text)")
                        //ws.send("Echo: \(text)")
                        let json = try JSONSerialization.jsonObject(with: Data(text.utf8), options: .allowFragments) as? [String: String]

                        print("parsed to JSON =  \(json)")

                            // HANDLE MESSAGES *****************************************************************

                        if let recipient = json?["recipient"] as? String,
                            let message = json?["message"] as? String {


                            let senderSettings = userSettings[user] ?? freshConfig()
                            let recipientSettings = userSettings[recipient] ?? freshConfig()

                            let fromUser = json?["from"] as? String
                            print("FROM: \(fromUser)")

                            print("Received message from \(user) or fromUser:\(fromUser) to \(recipient): \(message)") //using sender settings: \(senderSettings) and recipient settings: \(recipientSettings)")

                            // Send the message only to the intended recipient

                            let resps = clients[recipient] ?? []
                            print("auth resps = \(resps)")
                            //let resps = clients[recipient] ?? []
                           /// print("cmd resps = \(resps)")

                            resps.forEach { recipientSocket in

                                print("Received MESSAGE from \(user) or fromUser:\(fromUser) to \(recipient): ws\(recipientSocket)command:\(message)")// using sender settings: \(senderSettings) and recipient settings: \(recipientSettings)")

                                let logData: [String: String] = ["recipient": recipient, "message": message]
                                do {
                                    let logJSON = try JSONSerialization.data(withJSONObject: logData, options: [.fragmentsAllowed])
                                    let logString = String(data: logJSON, encoding: .utf8)

                                    recipientSocket.send(logString ?? "")
                                    print("Sent auth cmd from server to Swift binary.")
                                }
                                catch {
                                    print("error writing auth cmd")
                                }


                            }
                        } 
                        // HANDLE COMMANDS *****************************************************************
                        else if let recipient = json?["recipient"] as? String,
                             let command = json?["command"] as? String {


                            let senderSettings = userSettings[user] ?? freshConfig()
                            let recipientSettings = userSettings[recipient] ?? freshConfig()


                           let fromUser = json?["from"] as? String
                             print("FROM: \(fromUser)")

                            let resps = clients[recipient] ?? []
                            print("cmd resps = \(resps)")


                            resps.forEach { recipientSocket in

                                print("Received COMMAND from \(user) or fromUser:\(fromUser) to \(recipient): ws\(recipientSocket)command:\(command) using sender settings: \(senderSettings) and recipient settings: \(recipientSettings)")

                                let logData: [String: String] = ["recipient": recipient, "command": command]
                                do {
                                    let logJSON = try JSONSerialization.data(withJSONObject: logData, options: [.fragmentsAllowed])
                                    let logString = String(data: logJSON, encoding: .utf8)
                                    recipientSocket.send(logString ?? "")
                                    print("Sent auth cmd from server to Swift binary.")
                                }
                                catch {
                                    print("error writing auth cmd")
                                }


                            }
                        } else {
                            ws.send("Invalid command format")
                        }


                        if let scalar = unicodeScalarFromString(text), specs.contains(scalar) {
                            print("\(text)", terminator: "")
                        }
                        else {
                            print("\(text)")
                        }
                    }
                    catch {
                        print("error = \(error)")
                    }
                } else {



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
                        (user == "chris" && password == "swiftsage") 
                        ||
                        (user == "SERVER" && password == "supers3cre3t") 
                        ||
                        (user == "hackerman" && password == "swiftsage")                         
                        ||
                        (user == "chuck" && password == "swiftsage")  {
                            
                            // Authenticate the user
                            username = user
                            if clients[user] == nil {
                                clients[user] = []
                            }
                            clients[user]?.append(ws)

                            print("Authentication of \(user):\(ws) succeeded")


                            let resps = clients["SERVER"] ?? []
                            print("auth resps = \(resps)")

                            resps.forEach { recipientSocket in
                                print("Received message fpr recipientSocket = \(recipientSocket)")
                                    // send server auth cmd
                                    let logData: [String: String] = ["recipient": "SERVER", "command": "Authed \(user)"]
                                    do {
                                        let logJSON = try JSONSerialization.data(withJSONObject: logData, options: [.fragmentsAllowed])
                                        let logString = String(data: logJSON, encoding: .utf8)
                                        ws.send(logString ?? "")

                                       recipientSocket.send(logString ?? "")
                                       print("Sent auth cmd from server to Swift binary.")


                                    }
                                    catch {
                                        print("error writing auth cmd")
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
            }
            // else {


            //     if let scalar = unicodeScalarFromString(text), specs.contains(scalar) {
            //         print("\(text)", terminator: "")
            //     }
            //     else {
            //         print("\(text)")
            //     }
            
            //     if debugging {
            //             print("connectedClients")
            //             print(connectedClients)
            //     }
            //     for client in connectedClients {
            //         guard client !== ws else { 
            //             if debugging {
            //                 print("skipping self")
            //             }
            //             continue
            //         }
            //         if debugging {
            //             print("send to client =\(client)")
            //         }
            //         if (sendBuffer ) {

            //             updateMessageBuffer(with: text)
            //         }
            //         client.send("\(text)")
            //     }
            // }
            fflush(stdout)

        }
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

        ws.onClose.whenComplete { result in
            if true {
                if let user = username {
                    clients[user]?.removeAll(where: { $0 === ws })
                    if clients[user]?.isEmpty ?? false {
                        clients.removeValue(forKey: user)
                    }
                    print("Client disconnected: \(user)")
                }
            }
            // else {

            //     switch result {
            //     case .success:
            //         if debugging {

            //             print("Client disconnected")
            //         }
            //     case .failure(let error):
            //         print("Client disconnected with error: \(error)")
            //     }
            // }
        }
    }
    // dns-sd -R "MyWebSocketServer" _websocket._tcp . 8080
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

func unicodeScalarFromString(_ text: String) -> Unicode.Scalar? {
    if text != nil && !text.isEmpty {
        if text.unicodeScalars.isEmpty { return nil }
        if let scalar = text.unicodeScalars.first, text.unicodeScalars.count == 1 {
            return scalar
        }
    }
    return nil
}

// func updateMessageBuffer(with message: String) {
//     if !message.hasPrefix("say") {
//         messageBuffer.append(message)
//     }

//     if messageBuffer.count > bufferSize {
//         messageBuffer.removeFirst()
//     }
// }

// func sendBufferedMessages(to ws: WebSocket) {
//     messageBuffer.forEach { message in
//         ws.send(message)
//     }
// }


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