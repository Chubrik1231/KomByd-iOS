import SwiftUI
import MapKit

struct MapStopItem: Identifiable {
    let id: String
    let stop: Stop
    let coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    let stops: [Stop]

    // Centrum Bydgoszczy (Stary Rynek / Rondo Jagiellonów)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.1235, longitude: 18.0084),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @State private var selectedStop: Stop?

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region)
                .edgesIgnoringSafeArea(.bottom)

            VStack {
                Spacer()
                if let stop = selectedStop {
                    VStack(alignment: .leading, spacing: 8) {
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
                                Text("Odjazdy")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(KomBydTheme.accentBlue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(KomBydTheme.cardBackground)
                    .cornerRadius(16)
                    .shadow(radius: 8)
                    .padding()
                }
            }
        }
        .navigationTitle("Mapa Bydgoszczy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
