//
//  WeatherMapPlaceViewModel.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import CoreLocation
import Foundation
import MapKit

class WeatherMapPlaceViewModel: ObservableObject {

    // MARK:   published variables section - add variables that you need here and not that default location must be London

    /* Add other published varaibles that you are required here, you have been given one main one
     */

    @Published var weatherDataModel: WeatherDataModel?  // Holds weather data for the current location
    @Published var airDataModel: AirDataModel?  // Holds air quality data for the current location
    @Published var newLocation = "Battaramulla"
    // other attributes with suitable comments
    @Published var annotations: [MKPointAnnotation] = []  // Annotations for tourist places
    @Published var errorMessage: String?  // To store error messages for UI alerts

    private let apiKey = ""

    // MARK:  function to get coordinates safely for a place:
    func getCoordinatesForCity() async throws -> CLLocationCoordinate2D {
        guard !newLocation.isEmpty else {
            throw NSError(
                domain: "LocationError", code: 400,
                userInfo: [
                    NSLocalizedDescriptionKey: "City name cannot be empty."
                ])
        }

        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(newLocation)
        guard let location = placemarks.first?.location else {
            throw NSError(
                domain: "GeocodingError", code: 404,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Could not find coordinates for city: \(newLocation)"
                ])
        }

        return location.coordinate
    }

    // MARK: - Fetch Weather Data
    /// Fetches weather data for the given latitude and longitude.
    /// - Parameters:
    ///   - lat: Latitude of the location.
    ///   - lon: Longitude of the location.
    func fetchWeatherData(lat: Double, lon: Double) async throws {
        let urlString =
            "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw NSError(
                domain: "URLError", code: 400,
                userInfo: [
                    NSLocalizedDescriptionKey: "Invalid URL for weather data."
                ])
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        if let jsonString = String(data: data, encoding: .utf8) {
            print("API Response: \(jsonString)")
        }
        let weatherData = try JSONDecoder().decode(
            
            WeatherDataModel.self, from: data)
        DispatchQueue.main.async {
            self.weatherDataModel = weatherData
        }
    }

    // MARK: - Fetch Air Quality Data
    /// Fetches air quality data for the given latitude and longitude.
    /// - Parameters:
    ///   - lat: Latitude of the location.
    ///   - lon: Longitude of the location.
    func fetchAirQualityData(lat: Double, lon: Double) async throws {
        let urlString =
            "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw NSError(
                domain: "URLError", code: 400,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Invalid URL for air quality data."
                ])
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let airData = try JSONDecoder().decode(AirDataModel.self, from: data)
        DispatchQueue.main.async {
            self.airDataModel = airData
        }
    }

    // MARK: - Set Tourist Place Annotations
    /// Fetches and sets annotations for top tourist attractions using MapKit.
    func setAnnotations() async throws {
        guard let location = try? await getCoordinatesForCity() else {
            throw NSError(
                domain: "LocationError", code: 400,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Unable to fetch coordinates for the current location."
                ])
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Tourist Attractions"
        request.region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        DispatchQueue.main.async {
            self.annotations = response.mapItems.compactMap { item in
                let annotation = MKPointAnnotation()
                annotation.title = item.name
                annotation.coordinate = item.placemark.coordinate
                return annotation
            }
        }
    }
}
