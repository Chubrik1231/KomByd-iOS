import SwiftUI

struct StopsView: View {
    @State private var allStops: [Stop] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @AppStorage("favorite_stops") private var favoriteStopsData: String = ""

    private var favoriteStops: [Stop] {
        let favs = Set(favoriteStopsData.components(separatedBy: ","))
        return allStops.filter { favs.contains($0.numer) }
    }

    private var filteredStops: [Stop] {
        if searchText.isEmpty {
            return allStops
        } else {
            let query = searchText.lowercased()
            return allStops.filter {
                $0.displayName.lowercased().contains(query) ||
                $0.numer.contains(query) ||
                $0.starynumer.contains(query)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if !favoriteStops.isEmpty && searchText.isEmpty {
                    Section(header: Label("Ulubione przystanki", systemImage: "star.fill").foregroundColor(.yellow)) {
                        ForEach(favoriteStops) { stop in
                            NavigationLink(destination: StopDetailView(stop: stop)) {
                                StopRowView(stop: stop)
                            }
                        }
                    }
                }

                Section(header: Text(searchText.isEmpty ? "Wszystkie przystanki (\(allStops.count))" : "Wyniki wyszukiwania (\(filteredStops.count))")) {
                    if isLoading && allStops.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView("Pobieranie bazy przystanków...")
                            Spacer()
                        }
                        .padding()
                    } else if let error = errorMessage {
                        VStack(spacing: 8) {
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.red)
                            Button("Spróbuj ponownie") {
                                Task { await loadStops() }
                            }
                        }
                    } else {
                        ForEach(filteredStops.prefix(100)) { stop in
                            NavigationLink(destination: StopDetailView(stop: stop)) {
                                StopRowView(stop: stop)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Przystanki")
            .searchable(text: $searchText, prompt: "Wyszukaj przystanek lub nr słupka")
            .refreshable {
                await loadStops()
            }
            .task {
                if allStops.isEmpty {
                    await loadStops()
                }
            }
        }
    }

    private func loadStops() async {
        isLoading = true
        errorMessage = nil
        do {
            let res = try await APIService.shared.fetchStops()
            self.allStops = res
        } catch {
            self.errorMessage = "Nie udało się pobrać przystanków: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

struct StopRowView: View {
    let stop: Stop

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(stop.displayName)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text("nr \(stop.numer)")
                    .font(.caption.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(4)
            }
            if !stop.cleanDirection.isEmpty {
                Text(stop.cleanDirection)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }
}
