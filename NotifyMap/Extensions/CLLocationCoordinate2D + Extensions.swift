//
//  CLLocationCoordinate2D + Extensions.swift
//  NotifyMap
//
//  Created by Mehrdad Behrouz Ahmadian on 2024-01-08.
//

import MapKit

extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return fromLocation.distance(from: toLocation)
    }
}
