





import Network

protocol NetworkReachabilityProtocol: AnyObject {
    func isConnected() -> Bool
}

class NetworkReachability: NetworkReachabilityProtocol {
    
    func isConnected() -> Bool {
        
        let monitor = NWPathMonitor()
        var isConnected = false
        
        let semaphore = DispatchSemaphore(value: 0)
        
        monitor.pathUpdateHandler = { path in
            isConnected = path.status == .satisfied
            semaphore.signal()
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        
        semaphore.wait()
        monitor.cancel()
        
        return isConnected
    }
}
