//
//  SwiftUIView.swift
//  Hypnos02
//
//  Created by Euna Ahn on 2023/05/05.
//

import SwiftUI
import CoreLocation

struct SwiftUIView: View {
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    @State private var radius: Double = 0.0
    
    var body: some View {
        VStack {
            Text("Latitude: \(latitude)")
            Text("Longitude: \(longitude)")
            Text("Radius: \(radius) meters")
        }
        .onAppear {
            calculateRadius()
        }
    }

    func calculateRadius() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.requestLocation()
            if let location = locationManager.location {
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                
                let centerLocation = CLLocation(latitude: latitude, longitude: longitude)
                let destinationLocation = CLLocation(latitude: latitude + 1.0, longitude: longitude)

                radius = centerLocation.distance(from: destinationLocation)
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
