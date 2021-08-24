//
//  NetworkReachability.swift
//  Tawk Practice Test
//
//  Created by Fardan Akhter on 8/23/21.
//

import Foundation

class ConnectionManager {
    
    static let sharedInstance = ConnectionManager()
    private var reachability : Reachability!
    
    static var connectionStatusObserver: ((Reachability.Connection) -> Void) = {(_) in}
    
    func observeReachability(){
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        
        do {
            self.reachability = try Reachability()
            try self.reachability.startNotifier()
        }
        catch(let error) {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            print("Network available via Cellular Data.")
            break
        case .wifi:
            print("Network available via WiFi.")
            break
        case .unavailable:
            print("Network is not available.")
            break
        }
        
        ConnectionManager.connectionStatusObserver(reachability.connection)
    }
}
