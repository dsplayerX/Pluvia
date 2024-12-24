//
//  MapView.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
//    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    var places: [PlaceAnnotationDataModel]
    var selectedLocation: String
//
//    @State private var region: MKCoordinateRegion? = nil // Make this optional
    @State private var position: MapCameraPosition = .automatic
        @State private var selectedItem: MKMapItem?

        private var selectedPlace: PlaceAnnotationDataModel? {
            if let selectedItem {
                return places.first(where: { $0.id.hashValue == selectedItem.hashValue })
            }
            return nil
        }

    var body: some View {
        VStack {
            VStack {
                // Main Content
                VStack(alignment: .leading) {
                    Text(
                        "Tourist Attractions near \(selectedLocation.capitalized)"
                    )
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }.frame(maxWidth: .infinity, alignment: .leading)
                // Map showing the tourist places as pins
//                if region != nil {
//                    Map(coordinateRegion: .constant(region), annotationItems: weatherMapPlaceViewModel.touristAttractionPlaces) { place in
//                        MapMarker(coordinate: place.coordinate, tint: .red)
//                    }
                    Map(position: $position, selection: $selectedItem) {
                                ForEach(places, id: \.id) { place in
                                    Marker(
                                      place.name,
                                      coordinate: place.coordinate
                                    ).tag(place.id)
                                }
                            }
                    .frame(height: 300)
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            
                // List of all the tourist attraction places
                List(places) { place in
                    HStack{
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red).font(.system(size: 24))
                        VStack(alignment: .leading) {
                            
                            Text(place.name)
                                .font(.headline)
                            Text("LAT: \(place.coordinate.latitude), LON: \(place.coordinate.longitude)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }}
                }.listStyle(.automatic)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.top, -10)
                
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
