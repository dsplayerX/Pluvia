//
//  AirDataModel.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import Foundation

/* Code for AirDataModel Struct */
// MARK: - AirDataModel
struct AirDataModel: Codable {
    let coord: Coordinates
    let list: [AirData]
}

// MARK: - Coordinates
struct Coordinates: Codable {
    let lon: Double
    let lat: Double
}

// MARK: - AirData
struct AirData: Codable {
    let main: AirQualityIndex
    let components: AirComponents
    let dt: Int
}

// MARK: - AirQualityIndex
struct AirQualityIndex: Codable {
    let aqi: Int
}

// MARK: - AirComponents
struct AirComponents: Codable {
    let co: Double
    let no: Double
    let no2: Double
    let o3: Double
    let so2: Double
    let pm2_5: Double
    let pm10: Double
    let nh3: Double
}
