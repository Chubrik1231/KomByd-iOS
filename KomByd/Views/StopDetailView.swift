import SwiftUI

struct StopDetailView: View {
    let stop: Stop
    @State private var departures: [Departure] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var lastRefreshTime: Date = Date()
    @AppStorage("favorite_stops") private var favoriteStopsData: String = ""

    private var isFavorite: Bool {
        let favs = favoriteStopsData.components(separatedBy: ",").filter { !$0.isEmpty }
        return favs.contains(stop.numer)
    }

    var body: some View {
        List {
            // Nagłówek przystanku
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(stop.displayName)
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                            Text("Słupek nr \(stop.numer) • ZDMiKP: \(stop.starynumer)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: toggleFavorite) {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(isFavorite ? .yellow : .gray)
                        }
                        .buttonStyle(.plain)
                    }

                    if !stop.cleanDirection.isEmpty {
                        Text("Kierunki: \(stop.cleanDirection)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            // Odjazdy na żywo
            Section(header: HStack {
                Text("Odjazdy na żywo (GPS)")
                Spacer()
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }) {
                if isLoading && departures.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView("Pobieranie odjazdów...")
                        Spacer()
                    }
                    .padding(.vertical, 12)
                } else if let error = errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.title)
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                        Button("Odśwież") {
                            Task { await loadDepartures() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else if departures.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Text("Brak zaplanowanych odjazdów w najbliższym czasie")
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task { await loadDepartures() }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
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
            self.lastRefreshTime = Date()
        } catch {
            self.errorMessage = "Nie udało się połączyć: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
