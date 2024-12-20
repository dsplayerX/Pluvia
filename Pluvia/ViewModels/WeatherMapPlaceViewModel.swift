//
//  WeatherMapPlaceViewModel.swift
//  CWKTemplate24
//
//  Created by girish lukka on 23/10/2024.
//

import Foundation
class WeatherMapPlaceViewModel: ObservableObject {

    // MARK:   published variables section - add variables that you need here and not that default location must be London

    /* Add other published varaibles that you are required here, you have been given one main one
     */

    @Published var weatherDataModel: WeatherDataModel? 
    @Published var newLocation = "London"
    // other attributes with suitable comments

    // MARK:  function to get coordinates safely for a place:

    func getCoordinatesForCity() async throws {

        // write code for this function with suitable comments
    }

    // MARK:  function to fetch weather data safely from openweather using location coordinates

    func fetchWeatherData(lat: Double, lon: Double) async throws {

        // write code for this function with suitable comments
    }

    // MARK:  function to get tourist places safely for a  map region and store for use in showing them on a map

    func setAnnotations() async throws{

        // write code for this function with suitable comments
    }
}
