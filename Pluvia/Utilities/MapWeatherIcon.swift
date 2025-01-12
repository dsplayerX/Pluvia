//
//  MapWeatherIcon.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-24.
//

import Foundation

// Maps the weather condition ID to an SF Symbol name based on day/night
func mapWeatherIcon(for conditionID: Int, dt: Int, timezone: String)
    -> String
{
    let date = Date(timeIntervalSince1970: TimeInterval(dt))
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(identifier: timezone) ?? .current
    formatter.dateFormat = "HH"
    let hour = Int(formatter.string(from: date)) ?? 0
    let isDay = (hour >= 6 && hour < 18)

    switch conditionID {
    // Group 2xx: Thunderstorm
    case 200...232:
        return isDay ? "cloud.bolt.rain.fill" : "cloud.moon.bolt.fill"

    // Group 3xx: Drizzle
    case 300...321:
        return isDay ? "cloud.drizzle.fill" : "cloud.moon.drizzle.fill"

    // Group 5xx: Rain
    case 500...504:  // Light to extreme rain
        return isDay ? "cloud.rain.fill" : "cloud.moon.rain.fill"
    case 511:  // Freezing rain
        return isDay ? "snowflake" : "cloud.snow.fill"
    case 520...531:  // Shower rain
        return "cloud.heavyrain.fill"

    // Group 6xx: Snow
    case 600...622:
        return "cloud.snow.fill"

    // Group 7xx: Atmosphere (Mist, Smoke, Haze, etc.)
    case 701, 711, 731, 741, 751, 762, 771:
        return "cloud.fog.fill"

    case 721:  // Haze
        return isDay ? "sun.haze.fill" : "moon.haze.fill"

    case 761:  // Sand
        return isDay ? "sun.dust.fill" : "moon.dust.fill"

    case 781:  // Tornado
        return "tornado"

    // Group 800: Clear
    case 800:
        return isDay ? "sun.max.fill" : "moon.stars.fill"

    // Group 80x: Clouds
    case 801:  // Few clouds
        return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
    case 802:  // Scattered clouds
        return isDay ? "cloud.fill" : "cloud.moon.fill"
    case 803, 804:  // Broken and overcast clouds
        return "cloud.fill"

    // Default case for unknown conditions
    default:
        return "questionmark.circle.fill"
    }
}
