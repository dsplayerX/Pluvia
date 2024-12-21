//
//  LocationModel.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import Foundation
import SwiftData

// MARK:   LocationModel class to be used with SwiftData - database to store places information
// add suitable macro

@Model
class LocationModel {

    // MARK:  list of attributes to manage locations
    @Attribute(.unique) var name: String // City name
    var latitude: Double // Latitude
    var longitude: Double // Longitude
    
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
