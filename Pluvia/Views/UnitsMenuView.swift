//
//  UnitsMenuView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-26.
//


import SwiftUI

struct UnitsMenuView: View {
    @ObservedObject var viewModel: WeatherMapPlaceViewModel
    @Binding var isPresented: Bool // To close the popup menu

    var body: some View {
        NavigationView {
            VStack {
                // Unit selection options
                List {
                    Button(action: {
                        viewModel.useMetric = true
                        isPresented = false // Close the popup
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
                        isPresented = false // Close the popup
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
                        isPresented = false // Close the popup
                    }
                }
            }
        }
    }
}