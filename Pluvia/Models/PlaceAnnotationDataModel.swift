//
//  PlaceAnnotationDataModel.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import Foundation
import CoreLocation

/* Code  to manage tourist place map pins */

struct PlaceAnnotationDataModel: Identifiable {
    let id = UUID() // Unique identifier for each place
    let name: String // Name of the tourist place
    let coordinate: CLLocationCoordinate2D // Latitude and Longitude of the place

    init(name: String,latitude: Double, longitude: Double) {
        self.name = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
