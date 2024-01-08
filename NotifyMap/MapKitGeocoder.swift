//
//  MapKitGeocoder.swift
//  NotifyMap
//
//  Created by Mehrdad Behrouz Ahmadian on 2024-01-08.
//

import MapKit

enum GeocoderError: Error {
    case noResults
}

class MapKitGeocoder {
    func geocode(address: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let coordinate = placemarks?.first?.location?.coordinate {
                completion(.success(coordinate))
            } else {
                completion(.failure(GeocoderError.noResults))
            }
        }
    }
}
