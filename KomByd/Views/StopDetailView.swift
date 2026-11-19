import SwiftUI

struct StopDetailView: View {
    let stop: Stop
    @State private var departures: [Departure] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @AppStorage("favorite_stops") private var favoriteStopsData: String = ""

    private var isFavorite: Bool {
        let favs = favoriteStopsData.components(separatedBy: ",")
        return favs.contains(stop.numer)
    }

    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stop.displayName)
                            .font(.title2.bold())
                        Text("Słupek: nr \(stop.numer) • ID ZDMiKP: \(stop.starynumer)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if !stop.cleanDirection.isEmpty {
                            Text("Kierunki: \(stop.cleanDirection)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Button(action: toggleFavorite) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor(isFavorite ? .yellow : .gray)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
            }

            Section(header: Text("Rzeczywiste odjazdy (na żywo)")) {
                if isLoading && departures.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView("Ładowanie odjazdów...")
                        Spacer()
                    }
                    .padding()
                } else if let error = errorMessage {
                    VStack(alignment: .center, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                        Button("Spróbuj ponownie") {
                            Task { await loadDepartures() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else if departures.isEmpty {
                    VStack(alignment: .center, spacing: 8) {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Brak planowanych odjazdów w najbliższym czasie")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(departures) { dep in
                        DepartureRowView(departure: dep)
                    }
                }
            }
        }
        .navigationTitle(stop.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await loadDepartures()
        }
        .task {
            await loadDepartures()
        }
    }

    private func toggleFavorite() {
        var favs = favoriteStopsData.components(separatedBy: ",").filter { !$0.isEmpty }
        if favs.contains(stop.numer) {
            favs.removeAll { $0 == stop.numer }
        } else {
            favs.append(stop.numer)
        }
        favoriteStopsData = favs.joined(separator: ",")
    }

    private func loadDepartures() async {
        isLoading = true
        errorMessage = nil
        do {
            let res = try await APIService.shared.fetchDepartures(oldStopNumber: stop.starynumer)
            self.departures = res
        } catch {
            self.errorMessage = "Błąd pobierania odjazdów: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
