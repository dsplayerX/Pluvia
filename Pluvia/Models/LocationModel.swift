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
    @Attribute(.unique) var name: String
    var latitude: Double
    var longitude: Double

    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
