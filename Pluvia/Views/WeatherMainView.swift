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

    @State private var selectedCityIndex = 0
    @State private var isMapViewPresented = false
    @State private var isListViewPresented = false
    @State private var backgroundImage: String = "default_day_bg"
    @State private var bgImageColor: Color = .black  // Dynamic background color

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image(backgroundImage)
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
                        value: backgroundImage
                    )
            }

            VStack {
                if weatherMapPlaceViewModel.locations.isEmpty {
                    Spacer()
                    VStack {
                        Text("No locations added!")
                            .font(.system(size: 24))
                            .padding(5)
                            .shadow(radius: 2.5)
                        Text("Add a location to view weather data.")
                            .font(.system(size: 20))
                            .padding(5)
                            .shadow(radius: 2.5)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .background(.ultraThinMaterial.opacity(0.5))
                    .cornerRadius(10)
                    .padding(.horizontal, 60)
                    .padding(.top, 150)
                    Spacer()
                }

                TabView(selection: $selectedCityIndex) {
                    ForEach(
                        weatherMapPlaceViewModel.locations.indices, id: \.self
                    ) { index in
                        ScrollView(.vertical) {
                            CurrentWeatherView(bgImageColor: $bgImageColor)
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
                .onAppear {
                    Task {
                        do {
                            weatherMapPlaceViewModel.fetchLocationsData()
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
                        MapView(
                            places: weatherMapPlaceViewModel
                                .touristAttractionPlaces,
                            selectedLocation: weatherMapPlaceViewModel
                                .currentLocation, bgImageColor: $bgImageColor
                        )
                        .presentationDetents([.fraction(0.70), .large])
                        .presentationDragIndicator(.visible)
                        .background(bgImageColor.opacity(0.3))
                        .presentationBackground(.ultraThinMaterial)
                    }
                    .padding(.leading, 20)

                    Spacer()

                    // Dot Indicators
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(
                                    weatherMapPlaceViewModel.locations.indices,
                                    id: \.self
                                ) { index in
                                    Circle()
                                        .frame(width: 8, height: 8)
                                        .foregroundColor(
                                            index == selectedCityIndex
                                                ? .white : .gray
                                        )
                                        .onTapGesture {
                                            withAnimation {
                                                selectedCityIndex = index
                                            }
                                        }
                                }
                            }
                            .frame(minWidth: 200, alignment: .center)
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: 200)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    Gradient.Stop(
                                        color: selectedCityIndex <= 6
                                            ? Color.black.opacity(1)
                                            : Color.black.opacity(0),
                                        location: 0),
                                    Gradient.Stop(
                                        color: Color.black.opacity(1),
                                        location: 0.3),
                                    Gradient.Stop(
                                        color: Color.black.opacity(1),
                                        location: 0.7),
                                    Gradient.Stop(
                                        color: (selectedCityIndex
                                            >= weatherMapPlaceViewModel
                                            .locations.count - 6)
                                            ? Color.black.opacity(1)
                                            : Color.black.opacity(0),
                                        location: 1),
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .onChange(of: selectedCityIndex) { _, newValue in
                            withAnimation {
                                proxy.scrollTo(newValue, anchor: .center)
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
                        VisitedPlacesView(
                            bgImageColor: $bgImageColor,
                            selectedCityIndex: $selectedCityIndex
                        )
                        .background(bgImageColor.opacity(0.3))
                        .presentationDetents([.fraction(0.70), .large])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(.ultraThinMaterial)
                    }
                    .padding(.trailing, 20)
                }
                .padding()
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 5)
                        .ignoresSafeArea()
                )
                .padding(.bottom, 10)
                .padding(.top, -8)
                .safeAreaPadding(.bottom)

            }
            .safeAreaPadding(.top)
            .onChange(of: weatherMapPlaceViewModel.useMetric) {
                oldMetric, newMetric in
                Task {
                    do {
                        let coordinates =
                            try await weatherMapPlaceViewModel
                            .getCoordinatesForCity()
                        try await weatherMapPlaceViewModel.fetchWeatherData(
                            lat: coordinates.latitude,
                            lon: coordinates.longitude
                        )
                        try await weatherMapPlaceViewModel
                            .fetchAirQualityData(
                                lat: coordinates.latitude,
                                lon: coordinates.longitude
                            )
                    } catch {
                        weatherMapPlaceViewModel.errorMessage =
                            AlertMessage(
                                message: error.localizedDescription
                            )
                        print("Error: \(error.localizedDescription)")
                    }
                }

            }
            .onChange(of: weatherMapPlaceViewModel.locations) {
                oldLocation, newLocations in
                if !newLocations.isEmpty {
                    selectedCityIndex = 0  // Reset to the first city
                    Task {
                        do {
                            weatherMapPlaceViewModel.resetAll()
                            weatherMapPlaceViewModel.fetchLocationsData()
                            weatherMapPlaceViewModel.setNewLocation(
                                weatherMapPlaceViewModel.locations[
                                    selectedCityIndex
                                ].name
                            )
                            let coordinates =
                                try await weatherMapPlaceViewModel
                                .getCoordinatesForCity()
                            try await weatherMapPlaceViewModel.fetchWeatherData(
                                lat: coordinates.latitude,
                                lon: coordinates.longitude
                            )
                            try await weatherMapPlaceViewModel
                                .fetchAirQualityData(
                                    lat: coordinates.latitude,
                                    lon: coordinates.longitude
                                )
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
                                    message: error.localizedDescription
                                )
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }.ignoresSafeArea()
    }

    private func updateBackgroundImage(conditionID: Int) {
        let hour = Calendar.current.component(.hour, from: Date())
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
            bgImageColor = .black  // Default color if extraction fails
            return
        }
        bgImageColor = Color(uiColor: uiColor)
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
