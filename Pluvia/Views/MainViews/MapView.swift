//
//  MapView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import MapKit
import SwiftData
import SwiftUI

struct MapView: View {
    var places: [PlaceAnnotationDataModel] // List of tourist places
    var selectedLocation: String // Selected location

    @State private var position: MapCameraPosition = .automatic
    @State private var selectedPin: MKMapItem?
    @State private var selectedPlace: PlaceAnnotationDataModel?
    @Binding var bgImageColor: Color

    var body: some View {
        VStack {
            VStack {
                VStack(alignment: .leading) {
                    Text(
                        "Tourist Attractions"
                    )
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    Text("near \(selectedLocation.capitalized)")
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .padding(.horizontal, 25)
                }.frame(maxWidth: .infinity, alignment: .leading)
                Map(position: $position, selection: $selectedPin) {
                    ForEach(places.prefix(10), id: \.id) { place in
                        Marker(
                            place.name,
                            coordinate: place.coordinate
                        ).tag(place.id).tint(bgImageColor)
                    }
                }
                .animation(.spring, value: position)
                .frame(height: 350)
                .cornerRadius(15)
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }

            // List of top 10 the tourist attraction places
            VStack(alignment: .leading) {
                Text("Top 10 Must-Visit Attractions")
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(.white).padding(.horizontal, 20)
                    .shadow(radius: 10)

                List(places.prefix(10)) { place in
                    HStack {
                        Image(systemName: "mappin")
                            .foregroundColor(.white)
                            .font(.system(size: 18))

                        VStack(alignment: .leading) {
                            Text(place.name)
                                .font(.system(size: 16))
                                .foregroundColor(.white).shadow(radius: 10)
                                .padding(2.5)
                            Text(
                                "\(place.coordinate.latitude, specifier: "%.5f")° N, \(place.coordinate.longitude, specifier: "%.5f")° W"
                            )
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                            .shadow(radius: 10)
                        }
                        Spacer()
                    }
                    .shadow(radius: 10)
                    .padding(2.5)
                    .contentShape(
                        Rectangle()
                    )
                    .listRowBackground(bgImageColor.opacity(0.3))
                    .onTapGesture { // on tap of the list item, show the location on the map
                        selectedPlace = place
                        position = .region(
                            MKCoordinateRegion(
                                center: place.coordinate,
                                span: MKCoordinateSpan(
                                    latitudeDelta: 0.02,
                                    longitudeDelta: 0.02)
                            )
                        )
                    }
                    .swipeActions(edge: .trailing) { // swipe action to open maps app
                        Button {
                            openMaps(for: place)
                        } label: {
                            Label("Directions", systemImage: "map")
                        }
                        .tint(bgImageColor)
                    }
                }.listStyle(.plain)
                    .listRowInsets(EdgeInsets())
                    .scrollContentBackground(.hidden)
                    .cornerRadius(15)
                    .background(Color.clear)
                    .padding(.horizontal, 20)
            }.padding(.top, 10)
        }
    }

    // open maps app for more information of that place
    private func openMaps(for place: PlaceAnnotationDataModel) {
        let coordinate = place.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = place.name
        mapItem.openInMaps()
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: LocationModel.self)

        let viewModel = WeatherMapPlaceViewModel(
            modelContext: container.mainContext)

        // Mock data for preview
        viewModel.locations = [
            LocationModel(name: "India", latitude: 51.5074, longitude: -0.1278)
        ]

        return WeatherMainView()
            .environmentObject(viewModel)
            .modelContainer(container)
    } catch {
        fatalError(
            "Failed to create ModelContainer: \(error.localizedDescription)")
    }
}
