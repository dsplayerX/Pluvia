//
//  Secrets.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2025-01-12.
//


import Foundation

/// Load api key from Secrets.plist
struct Secrets {
    static var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path),
              let apiKey = dictionary["OPENWEATHER_API_KEY"] as? String else {
            fatalError("Secrets.plist is missing or OPENWEATHER_API_KEY not found.")
        }
        return apiKey
    }
}
