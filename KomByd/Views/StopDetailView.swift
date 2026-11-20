import SwiftUI

struct StopDetailView: View {
    let stop: Stop
    var initialFilterLine: String? = nil

    @State private var departures: [Departure] = []
    @State private var selectedLineFilter: String? = nil
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var lastRefreshTime: Date = Date()
    @AppStorage("favorite_stops") private var favoriteStopsData: String = ""

    private var isFavorite: Bool {
        let favs = favoriteStopsData.components(separatedBy: ",").filter { !$0.isEmpty }
        return favs.contains(stop.numer)
    }

    private var displayedDepartures: [Departure] {
        if let filter = selectedLineFilter, !filter.isEmpty {
            return departures.filter { $0.LineNumber == filter }
        }
        return departures
    }

    var body: some View {
        List {
            // Nagłówek przystanku
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(stop.displayName)
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                            Text("Słupek nr \(stop.numer) • ID ZDMiKP: \(stop.starynumer)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: toggleFavorite) {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(isFavorite ? .yellow : .gray)
                                .padding(8)
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

            // Pasek aktywnego filtra linii (jeśli użytkownik przeszedł z konkretnej linii w rozkładzie)
            if let filter = selectedLineFilter {
                Section {
                    HStack(spacing: 12) {
                        LineBadge(lineNumber: filter, isTram: (Int(filter) ?? 99) <= 12)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tylko linia \(filter)")
                                .font(.system(size: 15, weight: .bold))
                            Text("Filtrowanie odjazdów z rozkładu")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button(action: {
                            withAnimation {
                                selectedLineFilter = nil
                            }
                        }) {
                            Text("Pokaż wszystkie")
                                .font(.caption.bold())
                                .foregroundColor(KomBydTheme.accentBlue)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(KomBydTheme.accentBlue.opacity(0.12))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }
            }

            // Sekcja odjazdów na żywo
            Section(header: HStack {
                Text(selectedLineFilter != nil ? "Odjazdy linii \(selectedLineFilter!)" : "Odjazdy na żywo (GPS)")
                Spacer()
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }) {
                if isLoading && departures.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView("Pobieranie odjazdów GPS...")
                        Spacer()
                    }
                    .padding(.vertical, 16)
                } else if let error = errorMessage {
                    VStack(spacing: 10) {
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
                } else if displayedDepartures.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.title)
                            .foregroundColor(.secondary)
                        if let filter = selectedLineFilter {
                            Text("Brak zaplanowanych odjazdów dla linii \(filter) w najbliższym czasie")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button("Pokaż wszystkie linie na tym przystanku") {
                                withAnimation {
                                    selectedLineFilter = nil
                                }
                            }
                            .buttonStyle(.bordered)
                            .padding(.top, 4)
                        } else {
                            Text("Brak zaplanowanych odjazdów w najbliższym czasie")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                } else {
                    ForEach(displayedDepartures) { dep in
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
            if selectedLineFilter == nil && initialFilterLine != nil {
                selectedLineFilter = initialFilterLine
            }
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
            var oldNumber = stop.starynumer
            // Если starynumer пустой или равен номеру столба, находим точный номер из базы
            if oldNumber.isEmpty || oldNumber == stop.numer {
                let all = try await APIService.shared.fetchStops()
                if let found = all.first(where: { $0.numer == stop.numer }) {
                    oldNumber = found.starynumer
                }
            }

            let res = try await APIService.shared.fetchDepartures(oldStopNumber: oldNumber)
            self.departures = res
            self.lastRefreshTime = Date()
        } catch {
            self.errorMessage = "Nie udało się połączyć z ZDMiKP: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
