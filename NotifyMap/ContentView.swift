//
//  ContentView.swift
//  NotifyMap
//
//  Created by Mehrdad Behrouz Ahmadian on 2024-01-08.
//

import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    static let destination = CLLocationCoordinate2D(latitude: 43.7617, longitude: 79.4107)
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @StateObject var locationManager = LocationManager()
    @State private var destination: String = ""
    @StateObject private var notificationManager = NotificationManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    
    var body: some View {
        VStack {
            Map(position: $position, selection: $mapSelection) {
                UserAnnotation()
                
                ForEach(results, id: \.self) { item in
                    if routeDisplaying {
                        if item == routeDestination {
                            let placemark = item.placemark
                            Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                        }
                    } else {
                        let placemark = item.placemark
                        Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                    }
                }
                
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 6)
                }
            }
            .mapControls {
                MapCompass()
                MapUserLocationButton()
                MapPitchToggle()
            }
            .onChange(of: getDirections, { oldValue, newValue in
                if newValue {
                    fetchRoute()
                }
            })
            .onChange(of: mapSelection) { oldValue, newValue in
                showDetails = newValue != nil
            }
            .sheet(isPresented: $showDetails) {
                LocationsDetailsView(mapSelection: $mapSelection,
                                     show: $showDetails,
                                     getDirections: $getDirections)
                    .presentationDetents([.height(340)])
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                    .presentationCornerRadius(12)
            }
            
            DestinationInputView(destination: $destination) {
                geocodeDestination()
            }
        }
    }
    
    private func geocodeDestination() {
        Task {
            await searchPlaces()
        }
    }
}

extension ContentView {
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = destination
        request.region = viewModel.region
        let searchResults = try? await MKLocalSearch(request: request).start()
        
        DispatchQueue.main.async {
            self.results = searchResults?.mapItems ?? []
            
            // Assuming we want to focus on the first search result
            if let firstResultCoordinate = self.results.first?.placemark.coordinate {
                self.updateMapRegion(for: firstResultCoordinate)
            }
        }
    }
    
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            guard let userLocation = locationManager.userLocation else { return }
            
            request.source = MKMapItem(placemark: .init(coordinate: userLocation.coordinate))
            request.destination = mapSelection
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                
                withAnimation(.snappy) {
                    routeDisplaying = true
                    showDetails = false
                    
                    if let rect = route?.polyline.boundingMapRect, routeDisplaying {
                        let zoomFactor = 0.4 // 40% increase on each side
                        let additionalWidth = rect.size.width * zoomFactor
                        let additionalHeight = rect.size.height * zoomFactor

                        let zoomedOutRect = MKMapRect(
                            x: rect.origin.x - additionalWidth / 2,
                            y: rect.origin.y - additionalHeight / 2,
                            width: rect.size.width + additionalWidth,
                            height: rect.size.height + additionalHeight
                        )

                        position = .rect(zoomedOutRect)
                    }
                }
            }
        }
    }
}

extension ContentView {
    func updateMapRegion(for destinationCoordinate: CLLocationCoordinate2D) {
        guard let userLocation = locationManager.userLocation else { return }
        
        // Calculate Midpoint
        let midLatitude = (userLocation.coordinate.latitude + destinationCoordinate.latitude) / 2
        let midLongitude = (userLocation.coordinate.longitude + destinationCoordinate.longitude) / 2
        let midpoint = CLLocationCoordinate2D(latitude: midLatitude, longitude: midLongitude)
        
        // Calculate Span
        let distance = destinationCoordinate.distance(from: userLocation.coordinate)
        let span = MKCoordinateSpan(latitudeDelta: distance / 111320, longitudeDelta: distance / 111320)
        
        // Update region in viewModel and position
        let newRegion = MKCoordinateRegion(center: midpoint, span: span)
        viewModel.region = newRegion
        position = .region(newRegion)
    }
}

#Preview {
    ContentView()
}
