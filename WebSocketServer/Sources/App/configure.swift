import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import WebSocketKit
import func Darwin.fflush
import var Darwin.stdout

// configures your application
public func configure(_ app: Application) throws {
        var connectedClients: [WebSocket] = []

        app.http.server.configuration.hostname = "0.0.0.0"
    app.webSocket("ws") { req, ws in
     //   print("Client connected")
        connectedClients.append(ws)
        ws.onText { ws, text in

            if text == "." {
                print("\(text)", terminator: "")
            }
            else {
                print("\(text)")
            }
        
            fflush(stdout) // Explicitly flush the standard output

       // print("connectedClients")

        print(connectedClients)

            for client in connectedClients {
          //     print("send to client =\(client)")

                client.send("\(text)")
            }
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
                print("Client disconnected")
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

// func startAdvertisingWebSocketServer() {
//     let serviceName = "SwiftSageServer"
//     let serviceType = "_websocket._tcp."
//     let servicePort: UInt16 = 8080

//     let bonjour = Bonjour()
//     let service = BonjourService(name: serviceName, type: serviceType, port: Int32(servicePort))

//     do {
//         try bonjour.publish(service)
//         print("WebSocket server advertised via Bonjour")
//     } catch {
//         print("Failed to advertise WebSocket server: \(error)")
//     }
// }
// func startAdvertisingWebSocketServer() {
//     let serviceName = "SwiftSageServer"
//     let serviceType = "_websocket._tcp."
//     let servicePort: Int32 = 8080

//     let netService = NetService(domain: "local.", type: serviceType, name: serviceName, port: servicePort)
//     netService.publish()

//     print("WebSocket server advertised via Bonjour")
// }


// func startAdvertisingWebSocketServer() {
//     let serviceName = "MyWebSocketServer"
//     let serviceType = "_websocket._tcp"
//     let servicePort: UInt16 = 8080
    
//     let config = MulticastDNSServiceDiscovery.Configuration(serviceDiscoveryDomain: "local.", serviceName: "\(serviceName).\(serviceType)", servicePort: Int(servicePort))
//     let serviceDiscovery = MulticastDNSServiceDiscovery(configuration: config)
    
//     serviceDiscovery.start { result in
//         switch result {
//         case .success:
//             print("WebSocket server advertised via Bonjour")
//         case .failure(let error):
//             print("Failed to advertise WebSocket server: \(error)")
//         }
//     }
// }

// func startAdvertisingWebSocketServer() {
//     let serviceName = "SwiftSageServer"
//     let serviceType = "_websocket._tcp"
//     let servicePort: UInt16 = 8080

//     let registration = dns_sd.Registration(type: serviceType, domain: "local.", name: serviceName, port: servicePort)

//     registration.publish { result in
//         switch result {
//         case .success:
//             print("WebSocket server advertised via Bonjour")
//         case .failure(let error):
//             print("Failed to advertise WebSocket server: \(error)")
//         }
//     }
// }