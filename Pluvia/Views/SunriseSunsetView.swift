//
//  SunriseSunsetView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-24.
//

import SwiftUI

struct SunriseSunsetView: View {
    var sunriseTimestamp: Int
    var sunsetTimestamp: Int
    var timezone: String

    var timeZone: TimeZone {
        TimeZone(identifier: timezone) ?? .current
    }

    var sunriseTime: Date {
        Date(timeIntervalSince1970: TimeInterval(sunriseTimestamp))
    }

    var sunsetTime: Date {
        Date(timeIntervalSince1970: TimeInterval(sunsetTimestamp))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "sun.and.horizon")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))

                    Text("SUNRISE & SUNSET")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                }

                Spacer()

                HStack(spacing: 20) {
                    HStack {
                        Image(systemName: "sunrise.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color.yellow)

                        VStack {
                            Text("Sunrise")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white.opacity(0.7))

                            Text(DateFormatterUtils.formattedDate24Hour(
                                from: TimeInterval(sunriseTimestamp),
                                timeZone: timeZone
                            ))
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        }
                    }

                    Spacer()

                    HStack {
                        Image(systemName: "sunset.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color.orange)

                        VStack {
                            Text("Sunset")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white.opacity(0.7))

                            Text(DateFormatterUtils.formattedDate24Hour(
                                from: TimeInterval(sunsetTimestamp),
                                timeZone: timeZone
                            ))
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                HStack {
                    Text("Daylight Duration:")
                        .font(.system(size: 14))
                        .foregroundColor(.white)

                    Text(calculateDaylightDuration())
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .padding(.top, 10)
            }
            .padding(20)
        }
        .aspectRatio(2, contentMode: .fit)
    }

    private func calculateDaylightDuration() -> String {
        let daylightSeconds = sunsetTime.timeIntervalSince(sunriseTime)
        let hours = Int(daylightSeconds) / 3600
        let minutes = (Int(daylightSeconds) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

#Preview {
    SunriseSunsetView(
        sunriseTimestamp: Int(
            Date().addingTimeInterval(-6 * 3600).timeIntervalSince1970),  // Sunrise 6 hours ago
        sunsetTimestamp: Int(
            Date().addingTimeInterval(6 * 3600).timeIntervalSince1970),   // Sunset in 6 hours
        timezone: "America/New_York"
    )
    .padding()
}
