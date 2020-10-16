//
//  ViewController.swift
//  cocoaDemo
//
//  Created by Sourobrata Sarkar on 13/10/20.
//  Copyright © 2020 Sourobrata Sarkar. All rights reserved.
//

import UIKit
import NearBee
import UserNotifications
import CoreLocation

class ViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    
    var nearBee: NearBee!
    
    var viewBeacons:[NearBeeBeacon] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        UNUserNotificationCenter.current().delegate = self
        Logger.shared.log(logString: "init NearBee SDK")
        nearBee = NearBee.initNearBee()
        nearBee.delegate = self
        nearBee.enableBackgroundNotification(true)
        
        nearBee.stopMonitoringGeoFenceRegions()
//        nearBee.startScanning()
        nearBee.startMonitoringGeoFenceRegions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nearBee.delegate = self
    }


}




extension ViewController: NearBeeDelegate {
     // Callback for geofence enter event
    func didEnterGeofence(_ geofence: NearBeeGeoFence, _ attachment: GeoFenceAttachment) {
        Logger.shared.log(logString: "NearBee: didEnterGeofence callback")
    }
    
    func didFindBeacons(_ beacons: [NearBeeBeacon]) {
        print("did find beacon")
        Logger.shared.log(logString: "NearBee: didFindBeacons callback")
            for beacon in beacons {
                if !viewBeacons.contains(beacon) {
                    viewBeacons.insert(beacon, at: viewBeacons.count)
                }
            }
        }
        
        func didLoseBeacons(_ beacons: [NearBeeBeacon]) {
            print("did lose beacon")
            Logger.shared.log(logString: "NearBee: didLoseBeacons callback")
            for beacon in beacons {
                if viewBeacons.contains(beacon) {
                    viewBeacons.remove(at: viewBeacons.index(of: beacon)!)
                }
            }
        }
        
        func didUpdateBeacons(_ beacons: [NearBeeBeacon]) {
            print("did update beacon")
            Logger.shared.log(logString: "NearBee: didUpdateBeacons callback")
            for beacon in beacons {
                if viewBeacons.contains(beacon) {
                    viewBeacons.remove(at: viewBeacons.index(of: beacon)!)
                    viewBeacons.insert(beacon, at: viewBeacons.count)
                }
            }
        }
    
    func didThrowError(_ error: Error) {
        Logger.shared.log(logString: "NearBee: didthrowError callback")
        viewBeacons = []
    }
    
    func didUpdateState(_ state: NearBeeState) {
        Logger.shared.log(logString: "NearBee: didupdateState callback")
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let _ = nearBee.checkAndProcessNearbyNotification(response.notification)
        completionHandler()
    }
}

