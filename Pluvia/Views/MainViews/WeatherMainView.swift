//
//  WeatherBottomBar.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-20.
//

import SwiftData
import SwiftUI

struct WeatherMainView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    @State private var selectedCityIndex = 0  // Selected city index
    @State private var isMapViewPresented = false  // Map view presentation state
    @State private var isListViewPresented = false  // List view presentation state
    @State private var backgroundImage: String = "default_day_bg"  // Background image, default: clear day
    @State private var bgImageColor: Color = .blue  // Dynamic background color

    var body: some View {
        ZStack {
            BackgroundImageView(imageName: backgroundImage)
            VStack {
                if weatherMapPlaceViewModel.locations.isEmpty {
                    EmptyStateView(isListViewPresented: $isListViewPresented)
                }

                // Weather data view for each city
                TabView(selection: $selectedCityIndex) {
                    ForEach(
                        weatherMapPlaceViewModel.locations.indices, id: \.self
                    ) { index in
                        ScrollView(.vertical) {
                            CurrentWeatherView(bgImageColor: $bgImageColor)
                                .tag(index)
                                .frame(
                                    maxWidth: .infinity, maxHeight: .infinity
                                )
                                .padding(
                                    .horizontal, horizontalPaddingForDevice())
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.smooth, value: selectedCityIndex)
                .onChange(of: selectedCityIndex) { _, newValue in
                    handleCityChange(at: newValue)
                }
                .onAppear {
                    initializeWeatherData()
                }

                // Bottom navigation bar
                WeatherBottomBar(
                    isMapViewPresented: $isMapViewPresented,
                    isListViewPresented: $isListViewPresented,
                    selectedCityIndex: $selectedCityIndex,
                    bgImageColor: $bgImageColor
                )
                .environmentObject(weatherMapPlaceViewModel)
            }
            .safeAreaPadding(.top)
            .onChange(of: weatherMapPlaceViewModel.useMetric) {
                updateWeatherDataForMetricChange()
            }
            .onChange(of: weatherMapPlaceViewModel.locations) {
                _, newLocations in
                handleLocationsChange(newLocations: newLocations)
            }
        }.ignoresSafeArea()
    }

    /// Initialize weather data on app launch
    private func initializeWeatherData() {
        Task {
            do {
                // Fetch saved locations
                weatherMapPlaceViewModel.fetchLocationsData()

                // Fetch coordinates for the current location
                let coordinates =
                    try await weatherMapPlaceViewModel.getCoordinatesForCity()

                // Fetch weather data
                try await weatherMapPlaceViewModel.fetchWeatherData(
                    lat: coordinates.latitude,
                    lon: coordinates.longitude
                )

                // Fetch air quality data
                try await weatherMapPlaceViewModel.fetchAirQualityData(
                    lat: coordinates.latitude,
                    lon: coordinates.longitude
                )

                // Update the background image and color
                updateBackgroundImage(
                    conditionID: Int(
                        weatherMapPlaceViewModel.weatherDataModel?.current
                            .weather[0].id ?? 0)
                )
                extractBackgroundColor()

                // Fetch tourist attractions
                try await weatherMapPlaceViewModel.fetchTouristAttractions()
            } catch {
                // Handle errors and update the error message
                weatherMapPlaceViewModel.errorMessage = AlertMessage(
                    message: error.localizedDescription)
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    /// Handle city change when the user swipes to a new city
    /// - Parameter index: The index of the new city
    private func handleCityChange(at index: Int) {
        Task {
            do {
                weatherMapPlaceViewModel.resetAll()
                weatherMapPlaceViewModel.setNewLocation(
                    weatherMapPlaceViewModel.locations[index]
                        .name)
                let coordinates =
                    try await weatherMapPlaceViewModel
                    .getCoordinatesForCity()
                try await weatherMapPlaceViewModel.fetchWeatherData(
                    lat: coordinates.latitude,
                    lon: coordinates.longitude)
                try await weatherMapPlaceViewModel
                    .fetchAirQualityData(
                        lat: coordinates.latitude,
                        lon: coordinates.longitude)
                updateBackgroundImage(
                    conditionID:
                        Int(
                            weatherMapPlaceViewModel
                                .weatherDataModel?.current
                                .weather[0].id ?? 0))
                extractBackgroundColor()
                try await weatherMapPlaceViewModel
                    .fetchTouristAttractions()
            } catch {
                weatherMapPlaceViewModel.errorMessage =
                    AlertMessage(
                        message: error.localizedDescription)
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    /// Updates weather and air quality data when the metric preference changes
    private func updateWeatherDataForMetricChange() {
        Task {
            do {
                // Fetch coordinates of the current location
                let coordinates =
                    try await weatherMapPlaceViewModel.getCoordinatesForCity()

                // Fetch updated weather data based on the new metric preference
                try await weatherMapPlaceViewModel.fetchWeatherData(
                    lat: coordinates.latitude,
                    lon: coordinates.longitude
                )

                // Fetch updated air quality data
                try await weatherMapPlaceViewModel.fetchAirQualityData(
                    lat: coordinates.latitude,
                    lon: coordinates.longitude
                )
            } catch {
                // Handle errors and update the error message
                weatherMapPlaceViewModel.errorMessage = AlertMessage(
                    message: error.localizedDescription
                )
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    /// Handles changes to the locations array and updates weather-related data accordingly.
    private func handleLocationsChange(newLocations: [LocationModel]) {
        guard !newLocations.isEmpty else { return }

        selectedCityIndex = 0  // Reset to the first city

        Task {
            do {
                // Reset the ViewModel state
                weatherMapPlaceViewModel.resetAll()

                // Refresh the locations data
                weatherMapPlaceViewModel.fetchLocationsData()

                // Set the new location based on the first city
                weatherMapPlaceViewModel.setNewLocation(
                    weatherMapPlaceViewModel.locations[selectedCityIndex].name
                )

                // Fetch coordinates for the first city
                let coordinates =
                    try await weatherMapPlaceViewModel.getCoordinatesForCity()

                // Fetch updated weather data
                try await weatherMapPlaceViewModel.fetchWeatherData(
                    lat: coordinates.latitude,
                    lon: coordinates.longitude
                )

                // Fetch updated air quality data
                try await weatherMapPlaceViewModel.fetchAirQualityData(
                    lat: coordinates.latitude,
                    lon: coordinates.longitude
                )

                // Update background image and extract color
                updateBackgroundImage(
                    conditionID: Int(
                        weatherMapPlaceViewModel.weatherDataModel?.current
                            .weather[0].id ?? 0)
                )
                extractBackgroundColor()

                // Fetch tourist attractions for the new location
                try await weatherMapPlaceViewModel.fetchTouristAttractions()
            } catch {
                // Handle errors and display an alert message
                weatherMapPlaceViewModel.errorMessage = AlertMessage(
                    message: error.localizedDescription
                )
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    /// Update the background image based on the current weather condition
    private func updateBackgroundImage(conditionID: Int) {
        let hour: Int
        // Determine the current hour based on the timezone offset from the weather data
        if let timezoneOffsetString = weatherMapPlaceViewModel.weatherDataModel?
            .timezone,
            let timezoneOffset = Int(timezoneOffsetString)
        {
            // If the timezone offset is available, calculate the local time using the offset
            if let timezone = TimeZone(secondsFromGMT: timezoneOffset) {
                var calendar = Calendar.current
                calendar.timeZone = timezone
                hour = calendar.component(.hour, from: Date())  // Local hour in the specified timezone
            } else {
                // Fallback to the current system time if the timezone cannot be determined
                hour = Calendar.current.component(.hour, from: Date())
            }
        } else {
            // Default to system time if timezone data is not available
            hour = Calendar.current.component(.hour, from: Date())
        }

        // Determine if it is daytime or nighttime
        let isDay = hour >= 6 && hour < 18

        switch conditionID {
        // Group 2xx: Thunderstorm
        case 200...232:
            backgroundImage = "thunderstorm_bg"

        // Group 3xx: Drizzle
        case 300...321:
            backgroundImage = "drizzle_bg"

        // Group 5xx: Rain
        case 500...504, 520...531:
            backgroundImage = "rain_bg"
        case 511:
            backgroundImage = "snow_bg"  // Snow

        // Group 6xx: Snow
        case 600...622:
            backgroundImage = "snow_bg"

        // Group 7xx: Atmosphere
        case 701:
            backgroundImage = "mist_bg"
        case 711:
            backgroundImage = "smoke_bg"
        case 721:
            backgroundImage = "haze_bg"
        case 741:
            backgroundImage = "fog_bg"
        case 781:
            backgroundImage = "tornado_bg"

        // Group 800: Clear
        case 800:
            backgroundImage = isDay ? "clear_day_bg" : "clear_night_bg"

        // Group 80x: Clouds
        case 801:
            backgroundImage = isDay ? "cloudy_day_bg" : "cloudy_night_bg"
        case 802...804:
            backgroundImage = isDay ? "cloudy_day_bg" : "cloudy_night_bg"

        // Default case
        default:
            backgroundImage = isDay ? "default_day_bg" : "default_night_bg"
        }
    }

    // Extract dynamic background color from the current background image
    private func extractBackgroundColor() {
        guard let uiImage = UIImage(named: backgroundImage),
            let uiColor = uiImage.averageColor()
        else {
            bgImageColor = .blue  // Default color if extraction fails
            return
        }
        bgImageColor = Color(uiColor: uiColor)
    }

    // Returns the horizontal padding based on the device screen
    func horizontalPaddingForDevice() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height

        // Check for 11-inch and 13-inch devices
        if screenHeight >= 1366 {
            // 13-inch iPad (e.g., iPad Pro 12.9-inch)
            return 240  // Larger horizontal padding
        } else if screenHeight >= 1194 {
            // 11-inch iPad (e.g., iPad Pro 11-inch)
            return 150  // Smaller horizontal padding
        } else {
            // Other devices
            return 0  // No extra padding
        }
    }
}

struct BackgroundImageView: View {
    var imageName: String

    var body: some View {
        GeometryReader { geometry in
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(
                    width: geometry.size.width, height: geometry.size.height
                )
                .clipped()
                .ignoresSafeArea()
                .transition(
                    .opacity.combined(
                        with: .scale(scale: 1.05, anchor: .center))
                )
                .animation(
                    .easeInOut(duration: 0.5),
                    value: imageName
                )
        }
    }
}

/// A view to display when no locations are added.
struct EmptyStateView: View {
    @Binding var isListViewPresented: Bool
    var body: some View {
        VStack (alignment: .center, spacing: 10) {
            Image(systemName: "map.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.white.opacity(0.8))
                .shadow(radius: 5)

            Text("No Locations Added")
                .font(.system(size: 24))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(radius: 5).padding(.top, 10)

            Text(
                """
                Add your favorite locations to get real-time weather updates, \
                air quality insights, and nearby tourist attractions.
                """
            )
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 40)
            .shadow(radius: 2)
            .padding(.top, 5)

            if !isListViewPresented {
                Button(action: {
                    isListViewPresented.toggle()
                }) {
                    Text("Add Location")
                        .font(.system(size: 20))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 15)
                        .background(Color.white.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(15)
        .padding(.top, 100).shadow(radius: 10)
    }
}

#Preview {
    do {
        // Create a temporary ModelContainer for preview purposes
        let container = try ModelContainer(for: LocationModel.self)

        // Initialize the ViewModel with the model context
        let viewModel = WeatherMapPlaceViewModel(
            modelContext: container.mainContext)

        // Mock data for preview
        viewModel.locations = [
            //            LocationModel(name: "London", latitude: 51.5074, longitude: -0.1278)
        ]

        return WeatherMainView()
            .environmentObject(viewModel)
            .modelContainer(container)
    } catch {
        fatalError(
            "Failed to create ModelContainer: \(error.localizedDescription)")
    }
}
