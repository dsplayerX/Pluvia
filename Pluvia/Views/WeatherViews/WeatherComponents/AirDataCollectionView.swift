import SwiftUI

struct AirDataCollectionView: View {
    var airData: AirDataModel
    @Binding var bgImageColor: Color

    var body: some View {
        ZStack {
            BlurBackground()
                .cornerRadius(15)

            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "aqi.low")
                        .foregroundColor(Color.white.opacity(0.7))
                        .font(.system(size: 14))
                    Text("AIR QUALITY COMPONENTS")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                    spacing: 15
                ) {
                    ForEach(getComponents(), id: \.0) { component in
                        VStack(spacing: 5) {
                            Image(systemName: component.1)
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                            Text(component.0)
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                                .multilineTextAlignment(.center)
                            Text("\(component.2, specifier: "%.2f")")
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.1)))
                    }
                }
                .padding(10)

                HStack {
                    Spacer()
                    Text("measured in µg/m³")
                        .foregroundColor(.white)
                        .font(.system(size: 12))
                }
                .padding(.horizontal, 10)
                .padding(.top, -10).padding(.bottom, 10)
            }
        }
        .aspectRatio(2.5, contentMode: .fit)
    }

    private func getComponents() -> [(String, String, Double)] {
        guard let airComponents = airData.list.first?.components else {
            return []
        }

        return [
            ("CO", "wind", airComponents.co),
            ("NO", "flame.fill", airComponents.no),
            ("NO₂", "cloud.sun.bolt.fill", airComponents.no2),
            ("O₃", "sun.max.circle.fill", airComponents.o3),
            ("SO₂", "cloud.fog.fill", airComponents.so2),
            ("PM₂.₅", "aqi.low", airComponents.pm2_5),
            ("PM₁₀", "aqi.medium", airComponents.pm10),
            ("NH₃", "leaf.arrow.circlepath", airComponents.nh3),
        ]
    }
}

#Preview {
    let sampleAirData = AirDataModel(
        coord: Coordinates(lon: 78.9629, lat: 20.5937),
        list: [
            AirData(
                main: AirQualityIndex(aqi: 2),
                components: AirComponents(
                    co: 0.5, no: 0.2, no2: 1.1, o3: 2.3, so2: 0.9,
                    pm2_5: 1.5, pm10: 2.0, nh3: 0.4
                ),
                dt: 1_609_459_200
            )
        ]
    )
    return
        HStack {
            AirDataCollectionView(
                airData: sampleAirData, bgImageColor: .constant(.blue)
            )
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding(10)
        }
        .background(Color.blue)
}
