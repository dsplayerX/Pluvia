//
//  VisitedPlacesView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftData
import SwiftUI

struct VisitedPlacesView: View {
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel

    @State private var newCityName: String = ""
    @Binding var bgImageColor: Color

    var body: some View {
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
            .padding(.top, 30)

            HStack {
                TextField("Enter city name", text: $newCityName)
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
                        .padding(.vertical, 5)
                        .background(bgImageColor.opacity(0.3))
                        .shadow(radius: 10)
                        .blendMode(.screen)
                        .cornerRadius(5)
                }
                .disabled(newCityName.isEmpty)
            }
            .padding(.horizontal, 18)

            List(weatherMapPlaceViewModel.locations, id: \.name) { city in
                HStack {
                    Text(city.name.capitalized).font(.system(size: 16))
                        .foregroundColor(.white).fontWeight(.medium).shadow(
                            radius: 10)
                    Spacer()
                    VStack(alignment: .leading) {
                        Text(
                            "\(city.latitude, specifier: "%.5f")° N, \(city.longitude, specifier: "%.5f")° W"
                        )
                        .font(.system(size: 14)).foregroundColor(
                            .white.opacity(0.7)
                        ).fontWeight(.light).shadow(radius: 10)
                    }
                }.padding(.vertical, 20).padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(bgImageColor.opacity(0.3))
                    )
                    .padding(.vertical, -10)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task {
                                weatherMapPlaceViewModel.removeLocation(
                                    cityName: city.name)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }.tint(.clear)
                    }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .padding(.horizontal, 00)
            .alert(item: $weatherMapPlaceViewModel.errorMessage) {
                errorMessage in
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage.message),
                    dismissButton: .default(Text("OK")) {
                        weatherMapPlaceViewModel.errorMessage = nil
                    }
                )
            }
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
