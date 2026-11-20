import SwiftUI
import MapKit

struct MapStopAnnotation: Identifiable {
    var id: String { stop.numer }
    let stop: Stop
    let coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    let stops: [Stop]

    // Bydgoszcz centrum (Rondo Jagiellonów)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.1235, longitude: 18.0084),
        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
    )

    @State private var selectedStop: Stop?

    private var annotations: [MapStopAnnotation] {
        stops.compactMap { stop in
            if let coord = stop.coordinate {
                return MapStopAnnotation(stop: stop, coordinate: coord)
            }
            return nil
        }
    }

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: annotations.prefix(150)) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Button(action: {
                        selectedStop = item.stop
                    }) {
                        ZStack {
                            Circle()
                                .fill(KomBydTheme.accentBlue)
                                .frame(width: 30, height: 30)
                                .shadow(radius: 3)
                            Image(systemName: "tram.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)

            VStack {
                Spacer()
                if let stop = selectedStop {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(stop.displayName)
                                    .font(.headline)
                                Text("Słupek nr \(stop.numer)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            NavigationLink(destination: StopDetailView(stop: stop)) {
                                Text("Odjazdy GPS")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(KomBydTheme.accentBlue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(16)
                    .background(KomBydTheme.cardBackground)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, y: 5)
                    .padding()
                }
            }
        }
        .navigationTitle("Mapa Bydgoszczy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
