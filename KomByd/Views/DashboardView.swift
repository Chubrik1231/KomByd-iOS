import SwiftUI

struct DashboardView: View {
    @Binding var selectedTab: Int
    @State private var allStops: [Stop] = []
    @State private var latestNews: NewsItem?
    @State private var searchText: String = ""
    @State private var isShowingSearch = false
    @State private var isShowingTickets = false
    @State private var isShowingMap = false
    @AppStorage("favorite_stops") private var favoriteStopsData: String = ""

    private var favoriteStops: [Stop] {
        let favs = Set(favoriteStopsData.components(separatedBy: ",").filter { !$0.isEmpty })
        return allStops.filter { favs.contains($0.numer) }
    }

    private var searchResults: [Stop] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return []
        }
        let q = searchText.lowercased()
        return allStops.filter {
            $0.displayName.lowercased().contains(q) ||
            $0.numer.contains(q) ||
            $0.starynumer.contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Górny nagłówek KomByd
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("KomByd")
                                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                                    .foregroundColor(.primary)
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(KomBydTheme.liveGreen)
                                        .frame(width: 8, height: 8)
                                    Text("Bydgoszcz • Odjazdy na żywo")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            NavigationLink(destination: TicketsView()) {
                                Image(systemName: "ticket.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(KomBydTheme.accentBlue)
                                    .padding(10)
                                    .background(KomBydTheme.accentBlue.opacity(0.12))
                                    .clipShape(Circle())
                            }
                        }

                        // Szybkie pole wyszukiwania
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("Szukaj przystanku po nazwie lub numerze...", text: $searchText)
                                .textFieldStyle(.plain)
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(12)
                        .background(KomBydTheme.cardBackground)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Wyniki szybkiego wyszukiwania (jeśli wpisano tekst)
                    if !searchResults.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Wyniki wyszukiwania (\(searchResults.count))")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 0) {
                                ForEach(searchResults.prefix(8)) { stop in
                                    NavigationLink(destination: StopDetailView(stop: stop)) {
                                        StopRowView(stop: stop)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                    }
                                    Divider()
                                }
                            }
                            .background(KomBydTheme.cardBackground)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }

                    // MARK: - 4 GŁÓWNE PRZYCISKI W CENTRUM (2x2 GRID)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Szybkie menu")
                            .font(.headline)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            // 1. Wyszukaj przystanek
                            DashboardButton(
                                title: "Przystanki",
                                subtitle: "Szukaj i lista",
                                icon: "magnifyingglass",
                                color: KomBydTheme.accentBlue
                            ) {
                                selectedTab = 1
                            }

                            // 2. Rozkład jazdy / Linie
                            DashboardButton(
                                title: "Rozkład jazdy",
                                subtitle: "Linie i trasy",
                                icon: "tram.fill",
                                color: KomBydTheme.tramRed
                            ) {
                                selectedTab = 2
                            }

                            // 3. Mapa
                            NavigationLink(destination: MapView(stops: allStops)) {
                                DashboardButtonCard(
                                    title: "Mapa",
                                    subtitle: "Przystanki",
                                    icon: "map.fill",
                                    color: KomBydTheme.liveGreen
                                )
                            }
                            .buttonStyle(.plain)

                            // 4. Bilety okresowe
                            NavigationLink(destination: TicketsView()) {
                                DashboardButtonCard(
                                    title: "Bilety",
                                    subtitle: "Ważność biletów",
                                    icon: "ticket.fill",
                                    color: .orange
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - Ulubione przystanki
                    if !favoriteStops.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label("Ulubione przystanki", systemImage: "star.fill")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                Spacer()
                                Button("Wszystkie") {
                                    selectedTab = 3
                                }
                                .font(.subheadline)
                                .foregroundColor(KomBydTheme.accentBlue)
                            }
                            .padding(.horizontal)

                            VStack(spacing: 0) {
                                ForEach(favoriteStops.prefix(5)) { stop in
                                    NavigationLink(destination: StopDetailView(stop: stop)) {
                                        StopRowView(stop: stop)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                    }
                                    Divider()
                                }
                            }
                            .background(KomBydTheme.cardBackground)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }

                    // MARK: - Ostatni komunikat ZDMiKP
                    if let news = latestNews {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label("Komunikat ZDMiKP", systemImage: "bell.badge.fill")
                                    .font(.headline)
                                    .foregroundColor(KomBydTheme.tramRed)
                                Spacer()
                                Button("Więcej") {
                                    selectedTab = 4
                                }
                                .font(.subheadline)
                                .foregroundColor(KomBydTheme.accentBlue)
                            }
                            .padding(.horizontal)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(news.cleanTitle)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                Text(news.cleanDescription)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .lineLimit(3)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(KomBydTheme.cardBackground)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 30)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
            .task {
                await loadInitialData()
            }
        }
    }

    private func loadInitialData() async {
        do {
            let stops = try await APIService.shared.fetchStops()
            self.allStops = stops
        } catch {}

        do {
            let news = try await APIService.shared.fetchNews()
            if let first = news.first {
                self.latestNews = first
            }
        } catch {}
    }
}

// Karta przycisku dla NavigationLink
struct DashboardButtonCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(color)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KomBydTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
    }
}
