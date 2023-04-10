//
//  NetworkMonitor.swift
//  OnlineLibrary
//
//  Created by iosdev on 18.02.2023.
//

import UIKit
import Network

class NetworkMonitor {
    
    static let shared = NetworkMonitor()

    let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }
    var isReachableOnCellular: Bool = true

    func startMonitoring(completion: @escaping (_ isConnected: Bool) -> Void) {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isReachableOnCellular = path.isExpensive

            if path.status == .satisfied {
                print("We're connected!")
                completion(true)
                // post connected notification
            } else {
                print("No connection.")
                completion(false)
                // post disconnected notification
            }
            print(path.isExpensive)
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
