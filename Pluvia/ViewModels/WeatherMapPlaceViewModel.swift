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
    @Published var locations: [LocationModel] = []  // List of saved locations
    @Published var weatherDataModel: WeatherDataModel?  // Holds weather data for the current location
    @Published var airDataModel: AirDataModel?  // Holds air quality data for the current location
    @Published var currentLocation = ""  // City name to fetch weather
    @Published var touristAttractionPlaces: [PlaceAnnotationDataModel] = []  // Annotations for tourist places
    @Published var errorMessage: AlertMessage? = nil
    @Published var useMetric: Bool = true  // Use metric units by default

    private let apiKey = ""

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchLocationsData()

        // Set newLocation dynamically
        if locations.isEmpty {
            currentLocation = "London"
        } else {
            currentLocation = locations.first?.name ?? "London"  // Fallback to "London"
        }
    }

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

    func setNewLocation(_ location: String) {
        currentLocation = location
    }

    // MARK: - Add Location
    @MainActor
    func addLocation(cityName: String) {
        Task { [weak self] in
            guard let self = self else { return }  // Ensure `self` is still valid
            do {
                // Get coordinates for the city
                let coordinates = try await getCoordinates(cityName: cityName)

                // Check for duplicates
                guard
                    !locations.contains(where: {
                        $0.name.lowercased() == cityName.lowercased()
                    })
                else {
                    DispatchQueue.main.async {
                        self.errorMessage = AlertMessage(
                            message: "City already exists.")
                    }
                    return
                }

                // Create and save the new location
                let newLocation = LocationModel(
                    name: cityName, latitude: coordinates.latitude,
                    longitude: coordinates.longitude)
                modelContext.insert(newLocation)
                try modelContext.save()
                DispatchQueue.main.async {
                    self.fetchLocationsData()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = AlertMessage(
                        message:
                            "Could not add location! \(error.localizedDescription)"
                    )
                }
            }
        }
    }

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

    // MARK:  function to get coordinates safely for a place:
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

    // MARK:  function to get coordinates safely for a place:
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

    // MARK: - Fetch Weather Data
    /// Fetches weather data for the given latitude and longitude.
    /// - Parameters:
    ///   - lat: Latitude of the location.
    ///   - lon: Longitude of the location.
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
        DispatchQueue.main.async {
            self.weatherDataModel = weatherData
        }
    }

    // MARK: - Fetch Air Quality Data
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
        DispatchQueue.main.async {
            self.airDataModel = airData
        }
    }

    // MARK: - Set Tourist Place Annotations
    /// Fetches and sets annotations for top tourist attractions using MapKit.
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

        DispatchQueue.main.async {
            self.touristAttractionPlaces = places
        }
    }

    /// Resets all the data models and tourist places.
    func resetAll() {
        weatherDataModel = nil
        airDataModel = nil
        touristAttractionPlaces = []
    }
}

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}
