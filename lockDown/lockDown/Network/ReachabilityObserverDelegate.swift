//
//  ReachabilityObserverDelegate.swift
//  lockDown
//
//  Created by Aymen HECHMI on 12/05/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import Foundation
import Reachability

//Reachability
//declare this property where it won't go out of scope relative to your listener
fileprivate var reachability: Reachability!

protocol ReachabilityActionDelegate {
    func reachabilityChanged(_ isReachable: Bool, status: String)
}

protocol ReachabilityObserverDelegate: class, ReachabilityActionDelegate {
    func addReachabilityObserver() throws
    func removeReachabilityObserver()
}

// Declaring default implementation of adding/removing observer
extension ReachabilityObserverDelegate {
    
    /** Subscribe on reachability changing */
    func addReachabilityObserver() throws {
        reachability = try Reachability()
        
        reachability.whenReachable = { [weak self] reachability in
            
            switch reachability.connection {
            case .wifi:
                self?.reachabilityChanged(true, status: "wifi")
            case .cellular:
                self?.reachabilityChanged(true, status: "cellular")
            default:
                self?.reachabilityChanged(true, status: "other")
            }
            
        }
        reachability.whenUnreachable = { [weak self] reachability in
            self?.reachabilityChanged(false, status: "none")
        }
        try reachability.startNotifier()
    }
    
    /** Unsubscribe */
    func removeReachabilityObserver() {
        reachability.stopNotifier()
        reachability = nil
    }
}
