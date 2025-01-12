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
import SwiftUI

class WeatherMapPlaceViewModel: ObservableObject {

    // MARK: - Properties
    /// Core data context for managing database operations.
    var modelContext: ModelContext

    /// Published properties to update the UI
    @Published var locations: [LocationModel] = []  // List of saved locations
    @Published var weatherDataModel: WeatherDataModel?  // Holds weather data for the current location
    @Published var airDataModel: AirDataModel?  // Holds air quality data for the current location
    @Published var currentLocation = ""  // City name to fetch weather
    @Published var touristAttractionPlaces: [PlaceAnnotationDataModel] = []  // Annotations for tourist places
    @Published var errorMessage: AlertMessage? = nil  // Error message to display

    /// Metric units flag
    @AppStorage("useMetric") var useMetric: Bool = true  // Use metric units by default

    /// OpenWeather API key for accessing weather and air quality data.
    private let apiKey = Secrets.apiKey

    // MARK: - Initializer

    /// Initializes the ViewModel and loads saved locations. If no locations are available, defaults to London.
    /// - Parameter modelContext: The Core Data context used for managing database operations.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchLocationsData()

        // Set newLocation dynamically
        if locations.isEmpty {
            currentLocation = "London"
        } else {
            currentLocation = locations.first?.name ?? "London"  // Default to London if no locations are saved.
        }
    }

    /// Updates the current location.
    /// - Parameter location: The new location name.
    func setNewLocation(_ location: String) {
        currentLocation = location
    }

    // MARK: - Database Operations

    /// Fetches saved locations from the database and updates the `locations` property.
    func fetchLocationsData() {
        do {
            let descriptor = FetchDescriptor<LocationModel>(
                sortBy: [SortDescriptor(\.name)]
            )
            locations = try modelContext.fetch(descriptor)
        } catch {
            print("Fetching locations data failed.")
        }
    }

    /// Adds a new location to the database, ensuring no duplicates.
    /// - Parameter cityName: The name of the city to add.
    @MainActor
    func addLocation(cityName: String) {
        Task { [weak self] in
            guard let self = self else { return }  // Avoid retain cycles
            do {
                let coordinates = try await getCoordinates(cityName: cityName)

                guard
                    !locations.contains(where: {
                        $0.name.lowercased() == cityName.lowercased()
                    })
                else {
                    self.errorMessage = AlertMessage(
                        message: "City already exists.")
                    return
                }
                let newLocation = LocationModel(
                    name: cityName, latitude: coordinates.latitude,
                    longitude: coordinates.longitude)
                modelContext.insert(newLocation)
                try modelContext.save()

                // Refresh locations list
                self.fetchLocationsData()
            } catch {
                self.errorMessage = AlertMessage(
                    message:
                        "Could not add location! \(error.localizedDescription)"
                )
            }
        }
    }

    /// Removes a location from the database.
    /// - Parameter cityName: The name of the city to remove.
    @MainActor
    func removeLocation(cityName: String) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                guard
                    let locationToRemove = self.locations.first(where: {
                        $0.name.lowercased() == cityName.lowercased()
                    })
                else {
                    DispatchQueue.main.async {
                        self.errorMessage = AlertMessage(
                            message: "City not found.")
                    }
                    return
                }

                self.modelContext.delete(locationToRemove)
                try self.modelContext.save()

                DispatchQueue.main.async {
                    self.fetchLocationsData()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = AlertMessage(
                        message:
                            "Failed to remove location: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    // MARK: - Coordinate Fetching

    /// Retrieves geographic coordinates for a given city name.
    /// - Parameter cityName: The name of the city to fetch coordinates for.
    /// - Throws: An error if the city name is invalid or coordinates cannot be fetched.
    func getCoordinates(cityName: String) async throws -> CLLocationCoordinate2D
    {
        guard !cityName.isEmpty else {
            throw NSError(
                domain: "LocationError", code: 400,
                userInfo: [
                    NSLocalizedDescriptionKey: "City name cannot be empty."
                ])
        }

        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(cityName)
            guard let location = placemarks.first?.location else {
                throw NSError(
                    domain: "GeocodingError", code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Could not find coordinates for city \"\(cityName)\"."
                    ])
            }
            return location.coordinate
        } catch {
            throw NSError(
                domain: "GeocodingError", code: 500,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to fetch coordinates for city \"\(cityName)\"."
                ])
        }
    }

    /// Retrieves geographic coordinates for the current city name.
    /// - Throws: An error if the city name is invalid or coordinates cannot be fetched.
    func getCoordinatesForCity() async throws -> CLLocationCoordinate2D {
        guard !currentLocation.isEmpty else {
            throw NSError(
                domain: "LocationError", code: 400,
                userInfo: [
                    NSLocalizedDescriptionKey: "City name cannot be empty."
                ])
        }

        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(
                currentLocation)
            guard let location = placemarks.first?.location else {
                throw NSError(
                    domain: "GeocodingError", code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Could not find coordinates for city \"\(currentLocation)\"."
                    ])
            }
            return location.coordinate
        } catch {
            throw NSError(
                domain: "GeocodingError", code: 500,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to fetch coordinates for city \"\(currentLocation)\"."
                ])
        }
    }

    // MARK: - Fetch Suggestions to display in search bar
    /// Fetches location suggestions for the given query. The suggestions are sorted alphabetically.
    /// - Parameters:
    ///  - query: The search query to fetch suggestions for.
    ///  - completion: A closure to handle the fetched suggestions as an array of strings once the operation is complete or an empty array if no suggestions.
    func fetchSuggestions(
        for query: String, completion: @escaping ([String]) -> Void
    ) {
        guard !query.isEmpty else {
            completion([])
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Local search error: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let response = response else {
                print("No results found.")
                completion([])
                return
            }

            let suggestions: [String] = response.mapItems.compactMap {
                mapItem in
                guard let name = mapItem.name else { return nil }

                let components = [
                    name,
                    mapItem.placemark.administrativeArea,
                    mapItem.placemark.country,
                ].compactMap { $0 }  // Filters out nil values

                // Only include suggestions with valid address components
                guard components.count > 1 else { return nil }

                return components.joined(separator: ", ")
            }
            .sorted()
            completion(suggestions)
        }
    }

    // MARK: - Weather and Air Quality Data Fetching

    /// Fetches weather data for the specified coordinates.
    /// - Parameters:
    ///   - lat: Latitude of the location.
    ///   - lon: Longitude of the location.
    /// - Throws: An error if the API request fails or the data is invalid.
    @MainActor
    func fetchWeatherData(lat: Double, lon: Double) async throws {
        //        print("Fetching weather data for lat: \(lat), lon: \(lon)")
        let units = useMetric ? "metric" : "imperial"

        //        print("Fetching weather data for lat: \(lat), lon: \(lon)")
        let urlString =
            "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&units=\(units)&appid=\(apiKey)"
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
        //        print("Fetched Weather Data: \(weatherData.current.temp)")

        self.weatherDataModel = weatherData
    }

    /// Fetches air quality data for the given latitude and longitude.
    /// - Parameters:
    ///   - lat: Latitude of the location.
    ///   - lon: Longitude of the location.
    @MainActor
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
        self.airDataModel = airData
    }

    // MARK: - Set Tourist Place Annotations
    /// Fetches and sets annotations for top tourist attractions using MapKit.
    /// - Throws: An error if the current location is not set or the search fails.
    @MainActor
    func fetchTouristAttractions() async throws {
        guard !currentLocation.isEmpty else {
            throw NSError(
                domain: "LocationError", code: 400,
                userInfo: [
                    NSLocalizedDescriptionKey: "Current location is not set."
                ])
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "tourist attractions"
        request.region = MKCoordinateRegion(
            center: try await getCoordinatesForCity(),
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        // Map the search results to PlaceAnnotationDataModel
        let places = response.mapItems.map { mapItem in
            PlaceAnnotationDataModel(
                name: mapItem.name ?? "Unknown",
                latitude: mapItem.placemark.coordinate.latitude,
                longitude: mapItem.placemark.coordinate.longitude
            )
        }

        self.touristAttractionPlaces = places

    }

    // MARK: - Reset
    /// Resets all the data models and tourist places to their default state.
    func resetAll() {
        weatherDataModel = nil
        airDataModel = nil
        touristAttractionPlaces = []
    }
}

/// Represents an alert message to be displayed in the UI.
struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}
