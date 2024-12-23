//
//  WeatherMapPlaceViewModel.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import CoreLocation
import Foundation
@preconcurrency import MapKit
import SwiftData
import SwiftUICore

class WeatherMapPlaceViewModel: ObservableObject {

    // MARK:   published variables section - add variables that you need here and not that default location must be London

    /* Add other published varaibles that you are required here, you have been given one main one
     */
    var modelContext: ModelContext
    @Published var locations: [LocationModel] = [] // List of saved locations
    
    @Published var weatherDataModel: WeatherDataModel?  // Holds weather data for the current location
    @Published var airDataModel: AirDataModel?  // Holds air quality data for the current location
    @Published var currentLocation = ""  // City name to fetch weather
    @Published var annotations: [MKPointAnnotation] = []  // Annotations for tourist places
    @Published var errorMessage: AlertMessage? = nil
    
    private let apiKey = ""
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchLocationsData()

        // Set newLocation dynamically
        if locations.isEmpty {
            currentLocation = "London"
        } else {
            currentLocation = locations.first?.name ?? "London" // Fallback to "London" if no valid name exists
        }
    }
    
    func fetchLocationsData() {
               do {
                   let descriptor = FetchDescriptor<LocationModel>(
                    sortBy: [SortDescriptor(\.name)]
                   )
                   locations = try modelContext.fetch(descriptor)
               } catch {
                   print("Fetch failed")
               }
           }
    
        // MARK: - Add Location
    @MainActor
    func addLocation(cityName: String) {
        Task { [weak self] in
            guard let self = self else { return } // Ensure `self` is still valid
            do {
                // Get coordinates for the city
                let coordinates = try await getCoordinates(cityName: cityName)

                // Check for duplicates
                guard !locations.contains(where: { $0.name.lowercased() == cityName.lowercased() }) else {
                    DispatchQueue.main.async {
                        self.errorMessage = AlertMessage(message: "City already exists.")
                    }
                    return
                }

                // Create and save the new location
                let newLocation = LocationModel(name: cityName, latitude: coordinates.latitude, longitude: coordinates.longitude)
                modelContext.insert(newLocation)
                try modelContext.save()
                DispatchQueue.main.async {
                    self.fetchLocationsData()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = AlertMessage(message: "Failed to add location: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func removeLocation(cityName: String) {
        Task { [weak self] in
            guard let self = self else { return }

            do {
                // Find the location by its name
                guard let locationToRemove = self.locations.first(where: { $0.name.lowercased() == cityName.lowercased() }) else {
                    DispatchQueue.main.async {
                        self.errorMessage = AlertMessage(message: "City not found.")
                    }
                    return
                }

                // Remove the location from the model context
                self.modelContext.delete(locationToRemove)
                try self.modelContext.save()

                // Update the locations array
                DispatchQueue.main.async {
                    self.fetchLocationsData()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = AlertMessage(message: "Failed to remove location: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK:  function to get coordinates safely for a place:
    func getCoordinates(cityName: String) async throws -> CLLocationCoordinate2D {
        guard !cityName.isEmpty else {
            throw NSError(
                domain: "LocationError", code: 400,
                userInfo: [
                    NSLocalizedDescriptionKey: "City name cannot be empty."
                ])
        }

        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(cityName)
        guard let location = placemarks.first?.location else {
            throw NSError(
                domain: "GeocodingError", code: 404,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Could not find coordinates for city: \(cityName)"
                ])
        }

        return location.coordinate
    }
    
    func setNewLocation(_ location: String) {
        currentLocation = location
    }
    
    // MARK:  function to get coordinates safely for a place:
    func getCoordinatesForCity() async throws -> CLLocationCoordinate2D {
//        print("Fetching coord for current Location: \(currentLocation)")
    
        guard !currentLocation.isEmpty else {
            throw NSError(
                domain: "LocationError", code: 400,
                userInfo: [
                    NSLocalizedDescriptionKey: "City name cannot be empty."
                ])
        }

        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(currentLocation)
        guard let location = placemarks.first?.location else {
            throw NSError(
                domain: "GeocodingError", code: 404,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Could not find coordinates for city: \(currentLocation)"
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
//        print("Fetching weather data for lat: \(lat), lon: \(lon)")
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
//        print("Fetching air quality data for lat: \(lat), lon: \(lon)")
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
    
    func resetAll() {
        weatherDataModel = nil
        airDataModel = nil
        annotations = []
    }
}

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}
