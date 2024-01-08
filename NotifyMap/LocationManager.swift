//
//  LocationManager.swift
//  NotifyMap
//
//  Created by Mehrdad Behrouz Ahmadian on 2024-01-08.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    var destination: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        checkIfArrivedAtDestination()
    }
    
    private func checkIfArrivedAtDestination() {
        guard let userLocation = userLocation, let destination = destination else { return }
        
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        if userLocation.distance(from: destinationLocation) < 50 {
            // User has arrived at the destination
            NotificationCenter.default.post(name: .userDidArriveAtDestination, object: nil)
        }
    }
    
    func setDestination(_ coordinate: CLLocationCoordinate2D) {
        destination = coordinate
    }
}

extension Notification.Name {
    static let userDidArriveAtDestination = Notification.Name("userDidArriveAtDestination")
}
