//
//  NetServiceBrowserWrapper.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/24/23.
//

import Foundation
// Verify service discovery: Ensure that your iOS app is using the NetServiceBrowser to discover the advertised WebSocket service. The browser should be set to search for the same service type as the one advertised by the Vapor server, i.e., _websocket._tcp. Once the service is discovered, use the resolved IP address and port to establish a WebSocket connection from the iOS app.

import Foundation

class ServiceDiscovery: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    private var netServiceBrowser: NetServiceBrowser
    private var discoveredServices: [NetService] = []

    override init() {
        netServiceBrowser = NetServiceBrowser()
        super.init()
        netServiceBrowser.delegate = self
    }
//SwiftSageServer._sagess._tcp
    func startDiscovering() {
        netServiceBrowser.searchForServices(ofType: "_sagess._tcp", inDomain: "local.")
    }

    func stopDiscovering() {
        netServiceBrowser.stop()
    }

    // MARK: - NetServiceBrowserDelegate

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("Found service: \(service)")
        discoveredServices.append(service)
        service.delegate = self
        service.resolve(withTimeout: 10.0)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("Removed service: \(service)")
        if let index = discoveredServices.firstIndex(of: service) {
            discoveredServices.remove(at: index)
        }
    }

    // MARK: - NetServiceDelegate

    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let addressData = sender.addresses?.first(where: { $0.count == MemoryLayout<sockaddr_in>.size }) else { return }
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))

        addressData.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Void in
            let sockaddrPtr = pointer.bindMemory(to: sockaddr.self).baseAddress!
            if getnameinfo(sockaddrPtr, socklen_t(addressData.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                let ipAddress = String(cString: hostname)
                print("Resolved service (\(sender.name)) IP address: \(ipAddress), port: \(sender.port)")

                // Use ipAddress and sender.port to connect to the WebSocket server
                screamer.connectWebSocket(ipAddress: ipAddress, port: String(sender.port))
            }
            else {
                print("failed getnameinfo")
            }
        }
    }



    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("Failed to resolve service (\(sender.name)) with error: \(errorDict)")
    }
}
