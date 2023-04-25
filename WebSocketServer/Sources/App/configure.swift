import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import WebSocketKit
import func Darwin.fflush
import var Darwin.stdout

let debugging = false

// configures your application
public func configure(_ app: Application) throws {
    var connectedClients: [WebSocket] = []

    app.http.server.configuration.hostname = "0.0.0.0"

    app.webSocket("ws") { req, ws in
    if debugging {
       print("Client connected")
    }
        connectedClients.append(ws)
        ws.onText { ws, text in
 
            if text == "." {
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

                client.send("\(text)")
            }

             fflush(stdout) // Explicitly flush the standard output

        }
        ws.onBinary { ws, data in
            print("Received binary data: \(data)")
        }

        ws.onClose.whenComplete { result in
            if let index = connectedClients.firstIndex(where: { $0 === ws }) {
                connectedClients.remove(at: index)
            }

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
