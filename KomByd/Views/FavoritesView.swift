import SwiftUI

struct FavoritesView: View {
    @State private var allStops: [Stop] = []
    @State private var isLoading = false
    @AppStorage("favorite_stops") private var favoriteStopsData: String = ""

    private var favoriteStops: [Stop] {
        let favs = Set(favoriteStopsData.components(separatedBy: ",").filter { !$0.isEmpty })
        return allStops.filter { favs.contains($0.numer) }
    }

    var body: some View {
        NavigationStack {
            List {
                if favoriteStops.isEmpty {
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "star")
                            .font(.system(size: 48))
                            .foregroundColor(.yellow)
                        Text("Brak ulubionych przystanków")
                            .font(.headline)
                        Text("Dotknij gwiazdki przy dowolnym przystanku, aby dodać go tutaj do szybkiego podglądu.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                } else {
                    Section("Twoje zapisane przystanki") {
                        ForEach(favoriteStops) { stop in
                            NavigationLink(destination: StopDetailView(stop: stop)) {
                                StopRowView(stop: stop)
                            }
                        }
                        .onDelete(perform: removeFavorite)
                    }
                }
            }
            .navigationTitle("Ulubione")
            .task {
                if allStops.isEmpty {
                    do {
                        self.allStops = try await APIService.shared.fetchStops()
                    } catch {}
                }
            }
        }
    }

    private func removeFavorite(at offsets: IndexSet) {
        var favs = favoriteStopsData.components(separatedBy: ",").filter { !$0.isEmpty }
        let toRemove = offsets.map { favoriteStops[$0].numer }
        favs.removeAll { toRemove.contains($0) }
        favoriteStopsData = favs.joined(separator: ",")
    }
}
