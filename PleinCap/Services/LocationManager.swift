//
//  LocationManager.swift
//  PFE_APP
//
//  Created by chaabani achref on 13/6/2025.
//
import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var userLocation: CLLocation?
    @Published var isAuthorized: Bool = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
                    manager.startUpdatingLocation()
                }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        userLocation = latest
        // Keep updates lightweight; no need for constant GPS drain:
        manager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
            manager.startUpdatingLocation()
        default:
            isAuthorized = false
        }
    }
    func requestAuthorizationIfNeeded() {
           switch manager.authorizationStatus {
           case .notDetermined:
               manager.requestWhenInUseAuthorization()
           case .authorizedAlways, .authorizedWhenInUse:
               manager.startUpdatingLocation()
           case .denied, .restricted:
               // Optional: present a “Open Settings” flow
               break
           @unknown default:
               break
           }
       }


    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // You can log / surface if you want
        print("Location error:", error.localizedDescription)
    }
    
}


