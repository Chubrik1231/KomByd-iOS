import SwiftUI

struct StopsView: View {
    @State private var allStops: [Stop] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @AppStorage("favorite_stops") private var favoriteStopsData: String = ""

    private var favoriteStops: [Stop] {
        let favs = Set(favoriteStopsData.components(separatedBy: ",").filter { !$0.isEmpty })
        return allStops.filter { favs.contains($0.numer) }
    }

    private var filteredStops: [Stop] {
        let q = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if q.isEmpty {
            return allStops
        } else {
            return allStops.filter {
                $0.displayName.lowercased().contains(q) ||
                $0.numer.contains(q) ||
                $0.starynumer.contains(q)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty && !favoriteStops.isEmpty {
                    Section(header: Label("Ulubione", systemImage: "star.fill").foregroundColor(.yellow)) {
                        ForEach(favoriteStops) { stop in
                            NavigationLink(destination: StopDetailView(stop: stop)) {
                                StopRowView(stop: stop)
                            }
                        }
                    }
                }

                Section(header: Text(searchText.isEmpty ? "Wszystkie przystanki (\(allStops.count))" : "Wyniki (\(filteredStops.count))")) {
                    if isLoading && allStops.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView("Ładowanie przystanków...")
                            Spacer()
                        }
                        .padding()
                    } else if let error = errorMessage {
                        VStack(spacing: 8) {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.subheadline)
                            Button("Spróbuj ponownie") {
                                Task { await loadStops() }
                            }
                            .buttonStyle(.bordered)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        ForEach(filteredStops.prefix(80)) { stop in
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
            self.errorMessage = "Błąd: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

struct StopRowView: View {
    let stop: Stop

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(stop.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                if !stop.cleanDirection.isEmpty {
                    Text(stop.cleanDirection)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text("nr \(stop.numer)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .cornerRadius(8)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle()) // Уверенное и легкое нажатие по всей строке
    }
}
