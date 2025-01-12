//
//  MoonPhaseView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2025-01-11.
//
import SwiftUI

struct MoonPhaseView: View {
    var moonPhaseValue: Double  // Value between 0.0 (New Moon) and 1.0 (New Moon again)
    var moonriseTimestamp: Int?  // Unix time of moonrise
    var moonsetTimestamp: Int?  // Unix time of moonset

    private var illuminationPercentage: Double {
        let phaseAngle = moonPhaseValue * Double.pi
        return max(0, pow(sin(phaseAngle), 2) * 100)
    }

    private var formattedIlluminationPercentage: String {
        return String(format: "%.0f%%", illuminationPercentage)
    }

    private func formatTime(timestamp: Int?) -> String {
        guard let timestamp = timestamp, timestamp > 0 else {
            return "Not Available"
        }
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private var moonPhaseDescription: String {
        switch moonPhaseValue {
        case 0.0, 1.0: return "New Moon"
        case 0.01..<0.25: return "Waxing Crescent"
        case 0.25: return "First Quarter"
        case 0.25..<0.5: return "Waxing Gibbous"
        case 0.5: return "Full Moon"
        case 0.5..<0.75: return "Waning Gibbous"
        case 0.75: return "Last Quarter"
        case 0.75..<1.0: return "Waning Crescent"
        default: return "Unknown Phase"
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            BlurBackground().cornerRadius(15)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "moonphase.waxing.gibbous.inverse")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))

                    Text(moonPhaseDescription.uppercased())
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                }

                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Illumination")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(formattedIlluminationPercentage)")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        Divider()
                        HStack {
                            Text("Moonrise")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(formatTime(timestamp: moonriseTimestamp))")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        Divider()
                        HStack {
                            Text("Moonset")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(formatTime(timestamp: moonsetTimestamp))")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                    }.padding(.trailing, 10)

                    ZStack {
                        Image("moon_phase_bg")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .opacity(0.7)

                        Circle()
                            .fill(Color.black.opacity(0.8))
                            .frame(width: 120, height: 120)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        Gradient.Stop(color: Color.clear, location: max(CGFloat(illuminationPercentage / 100) - 0.05, 0)),
                                        Gradient.Stop(color: Color.black.opacity(0.8), location: CGFloat(illuminationPercentage / 100)),
                                        Gradient.Stop(color: Color.black.opacity(1.0), location: min(CGFloat(illuminationPercentage / 100) + 0.05, 1.0))
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }.padding(5)
                }
            }.padding(10)
        }
        .aspectRatio(2.5, contentMode: .fit)
    }
}

#Preview {
    MoonPhaseView(
        moonPhaseValue: 0.75,
        moonriseTimestamp: 1_684_941_060,
        moonsetTimestamp: 1_684_905_480
    )
    .padding()
    .background(Color.blue)
}
