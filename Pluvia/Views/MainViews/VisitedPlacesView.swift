//
//  VisitedPlacesView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftData
import SwiftUI
import SwipeActions

struct VisitedPlacesView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    @State private var newCityName: String = ""  // New city name to add
    @Binding var bgImageColor: Color
    @Binding var selectedCityIndex: Int
    @State private var showUnitSelection: Bool = false  // Show unit selection popup
    @State private var suggestions: [String] = []  // Search suggestions

    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading) {
                    Text("Saved Locations")
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, -30)

                // Search bar to search for and add a city
                HStack {
                    TextField("Search for a city", text: $newCityName)
                        .textFieldStyle(.plain)
                        .shadow(radius: 10)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.white.opacity(0.5), lineWidth: 1)
                        )
                        .padding(10)
                        .onChange(of: newCityName) { oldValue, newValue in
                            guard !newValue.isEmpty else {
                                suggestions = []
                                return
                            }

                            weatherMapPlaceViewModel.fetchSuggestions(
                                for: newValue
                            ) { results in
                                DispatchQueue.main.async {
                                    suggestions = results
                                }
                            }
                        }
                    // Button to add a city
                    Button(action: {
                        Task {
                            weatherMapPlaceViewModel
                                .addLocation(cityName: newCityName.capitalized)
                            newCityName = ""
                        }
                    }) {
                        Text("Add")
                            .buttonStyle(.borderedProminent)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(bgImageColor.opacity(0.3))
                            .shadow(radius: 10)
                            .blendMode(.screen)
                            .cornerRadius(5)
                    }
                    // .disabled(newCityName.isEmpty)
                }
                .padding(.horizontal, 20)

                // List of saved locations
                ZStack(alignment: .topLeading) {
                    if weatherMapPlaceViewModel.locations.isEmpty {
                        NoSavedLocationsView().frame(
                            maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        SwipeViewGroup {
                            List(weatherMapPlaceViewModel.locations, id: \.name)
                            {
                                city in
                                SwipeView {
                                    HStack {
                                        Text(city.name.capitalized).font(
                                            .system(size: 16)
                                        )
                                        .foregroundColor(.white).fontWeight(
                                            .medium
                                        )
                                        .shadow(
                                            radius: 10)
                                        Spacer()
                                        VStack(alignment: .leading) {
                                            Text(
                                                "\(city.latitude, specifier: "%.5f")° N, \(city.longitude, specifier: "%.5f")° W"
                                            )
                                            .font(.system(size: 14))
                                            .foregroundColor(
                                                .white.opacity(0.7)
                                            ).fontWeight(.light).shadow(
                                                radius: 10)
                                        }
                                    }
                                    .padding(.vertical, 25)
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity)
                                    .contentShape(
                                        Rectangle()
                                    ).overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                selectedCityIndex
                                                    == weatherMapPlaceViewModel
                                                    .locations
                                                    .firstIndex(where: {
                                                        $0.name == city.name
                                                    })
                                                    ? Color.white.opacity(
                                                        0.5)
                                                    : Color.clear,
                                                lineWidth: 1
                                            )
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(
                                                selectedCityIndex
                                                    == weatherMapPlaceViewModel
                                                    .locations
                                                    .firstIndex(where: {
                                                        $0.name == city.name
                                                    })
                                                    ? bgImageColor.opacity(
                                                        0.5)
                                                    : bgImageColor.opacity(
                                                        0.3)
                                            )
                                    )
                                    .cornerRadius(10)
                                    .onTapGesture(perform: {
                                        if let index =
                                            weatherMapPlaceViewModel
                                            .locations
                                            .firstIndex(where: {
                                                $0.name == city.name
                                            })
                                        {
                                            selectedCityIndex = index
                                        }
                                    })
                                } trailingActions: { _ in
                                    SwipeAction("Remove") {
                                        Task {
                                            weatherMapPlaceViewModel
                                                .removeLocation(
                                                    cityName: city.name)
                                        }
                                    }
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .bold))
                                    // .allowSwipeToTrigger() // TODO: fix this later. commented out because it does not work in current version of SwipeActions. causes scrollview to break
                                }
                                .swipeMinimumDistance(30) // temporary fix for the above issue
                                .swipeActionsStyle(.cascade)
                                .swipeActionCornerRadius(10)
                                .padding(.top, -10)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .alert(item: $weatherMapPlaceViewModel.errorMessage)
                            {
                                errorMessage in
                                Alert(
                                    title: Text("Error"),
                                    message: Text(errorMessage.message),
                                    dismissButton: .default(Text("OK")) {
                                        weatherMapPlaceViewModel.errorMessage =
                                            nil
                                    }
                                )
                            }
                        }.background(.clear)
                    }

                    if !suggestions.isEmpty {
                        List(suggestions, id: \.self) { suggestion in
                            HStack {
                                Text(suggestion)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(bgImageColor)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        Color.white.opacity(0.5), lineWidth: 1)
                            )
                            .onTapGesture {
                                Task {
                                    // Extract only the location name from the suggestion
                                    if let locationName = suggestion.split(
                                        separator: ","
                                    ).first {
                                        newCityName = String(locationName)
                                            .trimmingCharacters(
                                                in: .whitespacesAndNewlines)
                                    }
                                    weatherMapPlaceViewModel.addLocation(
                                        cityName: newCityName.capitalized
                                    )
                                    suggestions = []
                                    newCityName = ""
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .frame(maxHeight: 200)
                        .background(Color.clear)
                        .padding(.horizontal, 30)
                        .padding(.top, -10)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Label(
                            "Select Preferred Units",
                            systemImage: "ruler"
                        )
                        Button(action: {
                            weatherMapPlaceViewModel.useMetric = true
                        }) {
                            HStack {
                                if weatherMapPlaceViewModel.useMetric {
                                    Image(systemName: "checkmark")
                                }
                                Text("Metric")
                            }
                        }

                        Button(action: {
                            weatherMapPlaceViewModel.useMetric = false
                        }) {
                            HStack {
                                if !weatherMapPlaceViewModel.useMetric {
                                    Image(systemName: "checkmark")
                                }
                                Text("Imperial")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white).padding(.top, 30)
                    }
                }

            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct UnitsMenuView: View {
    @ObservedObject var viewModel: WeatherMapPlaceViewModel
    @Binding var isPresented: Bool  // To close the popup menu

    var body: some View {
        NavigationView {
            VStack {
                // Unit selection options
                List {
                    Button(action: {
                        viewModel.useMetric = true
                        isPresented = false  // Close the popup
                    }) {
                        HStack {
                            Text("Celsius")
                            Spacer()
                            if viewModel.useMetric {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }

                    Button(action: {
                        viewModel.useMetric = false
                        isPresented = false  // Close the popup
                    }) {
                        HStack {
                            Text("Fahrenheit")
                            Spacer()
                            if !viewModel.useMetric {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())

                Spacer()
            }
            .navigationTitle("Select Units")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false  // Close the popup
                    }
                }
            }
        }
    }
}

struct NoSavedLocationsView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "globe")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray.opacity(0.7))
            Text("No Locations Found")
                .font(.system(size: 20))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.top, 10)
            Spacer()
        }
        .padding()
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
