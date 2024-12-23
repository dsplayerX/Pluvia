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
    @Environment(\.colorScheme) var colorScheme

    @State private var selectedCityIndex = 0
    @State private var isMapViewPresented = false
    @State private var isListViewPresented = false

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image(dynamicBackgroundImage)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width, height: geometry.size.height
                    )
                    .clipped()
                    .ignoresSafeArea()
            }

            VStack {
                TabView(selection: $selectedCityIndex) {
                    ForEach(
                        weatherMapPlaceViewModel.locations.indices, id: \.self
                    ) { index in
                        ScrollView(.vertical) {
                            CurrentWeatherView()
                                .tag(index)
                                .frame(
                                    maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.smooth, value: selectedCityIndex)
                .onChange(of: selectedCityIndex) { oldValue, newValue in
                    Task {
                        do {
                            weatherMapPlaceViewModel.resetAll()
                            weatherMapPlaceViewModel.setNewLocation(
                                weatherMapPlaceViewModel.locations[newValue]
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
                        } catch {
                            weatherMapPlaceViewModel.errorMessage =
                                AlertMessage(
                                    message: error.localizedDescription)
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
                .onAppear {
                    Task {
                        do {
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
                            try await weatherMapPlaceViewModel.setAnnotations()
                        } catch {
                            weatherMapPlaceViewModel.errorMessage =
                                AlertMessage(
                                    message: error.localizedDescription)
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }

                // Bottom Bar
                HStack {
                    // Map Button
                    Button(action: {
                        isMapViewPresented.toggle()
                    }) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .sheet(isPresented: $isMapViewPresented) {
                        MapView()
                    }
                    .padding(.leading, 20)

                    Spacer()

                    // Dot Indicators
                    HStack(spacing: 8) {
                        ForEach(
                            weatherMapPlaceViewModel.locations.indices,
                            id: \.self
                        ) { index in
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(
                                    index == selectedCityIndex ? .white : .gray
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedCityIndex = index
                                    }
                                }
                        }
                    }

                    Spacer()

                    // List Button
                    Button(action: {
                        isListViewPresented.toggle()
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .sheet(isPresented: $isListViewPresented) {
                        VisitedPlacesView()
                    }
                    .padding(.trailing, 20)
                }
                .padding()
                .background(.ultraThinMaterial)
                .padding(.bottom, 10)
                .padding(.top, -8)
                .safeAreaPadding(.bottom)

            }
            .safeAreaPadding(.top)
            .onChange(of: isListViewPresented) { oldValue, newValue in
                if !oldValue {
                    // Refresh locations when the list view is dismissed
                    weatherMapPlaceViewModel.fetchLocationsData()
                    selectedCityIndex = 0
                }
                Task {
                    do {
                        weatherMapPlaceViewModel.resetAll()
                        weatherMapPlaceViewModel.setNewLocation(
                            weatherMapPlaceViewModel.locations[
                                selectedCityIndex
                            ].name)
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
                    } catch {
                        weatherMapPlaceViewModel.errorMessage =
                            AlertMessage(
                                message: error.localizedDescription)
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }.ignoresSafeArea()
    }

    private var dynamicBackgroundImage: String {
        guard let weatherData = weatherMapPlaceViewModel.weatherDataModel else {
            return colorScheme == .dark ? "default_night_bg" : "default_day_bg"  // Fallback default image
        }

        let conditionID = weatherData.current.weather[0].id
        let hour = Calendar.current.component(.hour, from: Date())
        let isDay = hour >= 6 && hour < 18

        switch conditionID {
        // Group 2xx: Thunderstorm
        case 200...232:
            return "thunderstorm_bg"

        // Group 3xx: Drizzle
        case 300...321:
            return "drizzle_bg"

        // Group 5xx: Rain
        case 500...504, 520...531:
            return "rain_bg"
        case 511:
            return "snow_bg"  // Snow

        // Group 6xx: Snow
        case 600...622:
            return "snow_bg"

        // Group 7xx: Atmosphere
        case 701:
            return "mist_bg"
        case 711:
            return "smoke_bg"
        case 721:
            return "haze_bg"
        case 741:
            return "fog_bg"
        case 781:
            return "tornado_bg"

        // Group 800: Clear
        case 800:
            return isDay ? "clear_day_bg" : "clear_night_bg"

        // Group 80x: Clouds
        case 801:
            return isDay ? "cloudy_day_bg" : "cloudy_night_bg"
        case 802...804:
            return isDay ? "cloudy_day_bg" : "cloudy_night_bg"

        // Default case
        default:
            return isDay ? "default_day_bg" : "default_night_bg"
        }
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
            LocationModel(name: "London", latitude: 51.5074, longitude: -0.1278)
        ]

        return WeatherMainView()
            .environmentObject(viewModel)
            .modelContainer(container)
    } catch {
        fatalError(
            "Failed to create ModelContainer: \(error.localizedDescription)")
    }
}
