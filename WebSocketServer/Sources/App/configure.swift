import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import WebSocketKit
import func Darwin.fflush
import var Darwin.stdout

let debugging = true

let sendBuffer = false
let useAuth = true
let specs  = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "▇", "▆", "▅", "▄", "▃", "▂", "▁"] + 
             ["░", "▒", "▓", "█","░", "▒","▓", "█","░", "▒","░", "▒", "▓", "█","░"] + ["."]
  
let bufferSize = 100
  
var messageBuffer: [String] = []
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
        
        
        if (sendBuffer ) {
            sendBufferedMessages(to: ws)
        }

        ws.onText { ws, text in

            if useAuth {
                if let user = username {
                    do {
                        print("Received MSG from \(user): \(text)")
                        //ws.send("Echo: \(text)")
                        let json = try JSONSerialization.jsonObject(with: Data(text.utf8), options: .allowFragments) as? [String: String]


                        print("parsed to JSON =  \(json)")

                            // HANDLE MESSAGES *****************************************************************

                        if let recipient = json?["recipient"] as? String,
                            let message = json?["message"] as? String {

                            let fromUser = json?["from"] as? String
                             print("FROM: \(fromUser)")

                            print("Received message from \(user) to \(recipient): \(message)")

                            // Send the message only to the intended recipient

                            let resps = clients[recipient] ?? []
                            print("auth resps = \(resps)")

                            resps.forEach { recipientSocket in
                                print("Received message fpr recipientSocket = \(recipientSocket)")

                                recipientSocket.send("\(message)")
                            }
                        } 
                        // HANDLE COMMANDS *****************************************************************
                        else if let recipient = json?["recipient"] as? String,
                             let command = json?["command"] as? String {



                           let fromUser = json?["from"] as? String
                             print("FROM: \(fromUser)")

                            let resps = clients[recipient] ?? []
                            print("cmd resps = \(resps)")

                            resps.forEach { recipientSocket in
                                print("Received message fpr recipientSocket = \(recipientSocket)")

                                recipientSocket.send("\(command)")
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
                        (user == "hackerman" && password == "swiftsage") 
                        ||
                        (user == "SERVER" && password == "supers3cre3t") 
                        ||
                        (user == "chuck" && password == "n1c3")  {
                            
                  // Authenticate the user
                    username = user
                    if clients[user] == nil {
                        clients[user] = []
                    }
                    clients[user]?.append(ws)

                            print("Authentication of \(user):\(ws) succeeded")
                        }
                        else {
                            print("Invalid username or password)")
                        }
                    } catch {
                        print("Invalid JSON)")
                    }
                }
            }
            else {


                if let scalar = unicodeScalarFromString(text), specs.contains(scalar) {
                    print("\(text)", terminator: "")
                }
                else {
                    print("\(text)")
                }
            
                if debugging {
                        print("connectedClients")
                        print(connectedClients)
                }
                for client in connectedClients {
                    guard client !== ws else { 
                        if debugging {
                            print("skipping self")
                        }
                        continue
                    }
                    if debugging {
                        print("send to client =\(client)")
                    }
                    if (sendBuffer ) {

                        updateMessageBuffer(with: text)
                    }
                    client.send("\(text)")
                }
            }
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
            if useAuth {
                if let user = username {
                    clients[user]?.removeAll(where: { $0 === ws })
                    if clients[user]?.isEmpty ?? false {
                        clients.removeValue(forKey: user)
                    }
                    print("Client disconnected: \(user)")
                }
            }
            else {

                switch result {
                case .success:
                    if debugging {

                        print("Client disconnected")
                    }
                case .failure(let error):
                    print("Client disconnected with error: \(error)")
                }
            }
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
        if let scalar = text.unicodeScalars.first, text.unicodeScalars.count == 1 {
            return scalar
        }
    }
    return nil
}

func updateMessageBuffer(with message: String) {
    if !message.hasPrefix("say") {
        messageBuffer.append(message)
    }

    if messageBuffer.count > bufferSize {
        messageBuffer.removeFirst()
    }
}

func sendBufferedMessages(to ws: WebSocket) {
    messageBuffer.forEach { message in
        ws.send(message)
    }
}