//
//  WeatherBottomBar.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-20.
//

import SwiftData
import SwiftUI

struct WeatherStyleBottomBarView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

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
                                weatherMapPlaceViewModel.locations[newValue].name)
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
                            weatherMapPlaceViewModel.locations[selectedCityIndex].name)
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
            return "BG"  // Fallback image
        }

        let condition = weatherData.current.weather[0].main.rawValue
            .lowercased()
        let hour = Calendar.current.component(.hour, from: Date())

        switch condition {
        case "clear":
            return hour >= 6 && hour < 18 ? "BG" : "BG"
        case "clouds":
            return hour >= 6 && hour < 18 ? "BG" : "BG"
        case "rain":
            return "rainy"
        case "snow":
            return "snowy"
        case "thunderstorm":
            return "stormy"
        default:
            return "defaultBackground"
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

        return WeatherStyleBottomBarView()
            .environmentObject(viewModel)
            .modelContainer(container)
    } catch {
        fatalError(
            "Failed to create ModelContainer: \(error.localizedDescription)")
    }
}
