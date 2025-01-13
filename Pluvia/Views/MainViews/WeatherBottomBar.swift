//
//  WeatherBottomBar.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2025-01-13.
//

import SwiftUI

struct WeatherBottomBar: View {
    @Binding var isMapViewPresented: Bool
    @Binding var isListViewPresented: Bool
    @Binding var selectedCityIndex: Int
    @EnvironmentObject var weatherMapPlaceViewModel: WeatherMapPlaceViewModel
    @Binding var bgImageColor: Color

    var body: some View {
        HStack {
            // Map Button
            Button(action: {
                isMapViewPresented.toggle()
            }) {
                Image(systemName: "map")
                    .font(.system(size: 24))
                    .foregroundColor(
                        weatherMapPlaceViewModel.locations.isEmpty
                            ? .gray : .white
                    )
            }.disabled(weatherMapPlaceViewModel.locations.isEmpty)  // if no locations, disable the button
                .sheet(isPresented: $isMapViewPresented) {
                    MapView(
                        places: weatherMapPlaceViewModel
                            .touristAttractionPlaces,
                        selectedLocation: weatherMapPlaceViewModel
                            .currentLocation,
                        bgImageColor: $bgImageColor
                    )
                    .presentationDetents(detentsForDevice())
                    .presentationDragIndicator(.visible)
                    .background(bgImageColor.opacity(0.3))
                    .presentationBackground(.ultraThinMaterial)
                    .preferredColorScheme(.dark)
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
                                    index == selectedCityIndex ? .white : .gray
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
                                color: Color.black.opacity(1), location: 0.3),
                            Gradient.Stop(
                                color: Color.black.opacity(1), location: 0.7),
                            Gradient.Stop(
                                color: (selectedCityIndex
                                    >= weatherMapPlaceViewModel.locations.count
                                    - 6)
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
                .preferredColorScheme(.dark)
            }
            .padding(.trailing, 20)
        }
        .padding()
        .padding(.bottom, bottomPaddingForDevice())
        .background(
            BlurBackground().ignoresSafeArea()
                .overlay(
                    VStack {
                        Divider().background(Color.white.opacity(0.7))
                        Spacer()
                    }
                )
        )
        .padding(.top, -8)
        .safeAreaPadding(.bottom)
    }

    // Returns the detents based on the device screen size
    func detentsForDevice() -> Set<PresentationDetent> {
        let screenHeight = UIScreen.main.bounds.height

        if screenHeight >= 1024 {
            // Larger devices like iPads
            return [.large]
        } else if screenHeight >= 812 {
            // Devices like iPhone 16 Pro, iPhone 16 Pro Max
            return [.fraction(0.70), .large]
        } else {
            // Smaller devices like iPhone SE
            return [.large]
        }
    }

    // Returns the bottom padding based on the device screen size
    func bottomPaddingForDevice() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height

        if screenHeight <= 667 {
            // iPhone SE or similarly small devices
            return -15
        } else {
            // All other devices
            return 10
        }
    }
}
