//
//  ActivityManager.swift
//  lockDown
//
//  Created by Aymen HECHMI on 13/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import Foundation
import CoreMotion

protocol ActivityManagerDelegate: AnyObject {
    func activityDidUpdate(data: CMMotionActivity, motionManager: CMMotionManager)
}

class ActivityManager: NSObject{
    
     weak var delegate: ActivityManagerDelegate?
    
    // MARK: - Private properties
    private var activityManager = CMMotionActivityManager()
    private var isAuthorized = false
    private var data : [CMMotionActivity]!
    private var queue = OperationQueue()
    private var motionManager = CMMotionManager()

    func checkAuthorization(andThen f:(()->())? = nil) {
        guard CMMotionActivityManager.isActivityAvailable() else {
            print("darn")
            return
        }
        // new in iOS 11, we can just ask for the authorization status
        let status = CMMotionActivityManager.authorizationStatus()
        switch status {
        case .notDetermined: // bring up dialog
            let now = Date()
            self.activityManager.queryActivityStarting(from: now, to:now, to:.main) {
                _,err in
                print("CMMotionActivityManager asked for authorization")
                if err == nil {
                    f?()
                }
            }
        case .authorized: f?()
        case .restricted: break // do nothing
        case .denied: break // could beg for authorization here
        @unknown default:
            fatalError("CMMotionActivityManager asked for authorization")
        }
    }
    
    func startActivityScan() {
        self.checkAuthorization(andThen: self.reallyStart)
    }
    
    private func reallyStart() {
        
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()
        
        let now = Date()
        let yester = now - (60*60*24)
        
        self.activityManager.queryActivityStarting(from: yester, to: now, to: self.queue) { arr, err in
            guard var acts = arr else {return}
            // crude filter: eliminate empties, low-confidence, and successive duplicates
            let blank = "f f f f f f"
            acts = acts.filter {act in act.overallAct() != blank}
            acts = acts.filter {act in act.confidence == .high}
            acts = acts.filter {act in !(act.automotive && act.stationary)}
            for i in (1..<acts.count).reversed() {
                if acts[i].overallAct() == acts[i-1].overallAct() {
                    print("removing act identical to previous")
                    acts.remove(at:i)
                }
            }
            DispatchQueue.main.async {
                self.data = acts
                self.delegate?.activityDidUpdate(data: self.data.last!, motionManager: self.motionManager)
            }
        }
    }
}
