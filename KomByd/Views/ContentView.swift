import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Pulpit", systemImage: "square.grid.2x2.fill")
                }
                .tag(0)

            StopsView()
                .tabItem {
                    Label("Przystanki", systemImage: "magnifyingglass")
                }
                .tag(1)

            LinesView()
                .tabItem {
                    Label("Linie", systemImage: "tram.fill")
                }
                .tag(2)

            FavoritesView()
                .tabItem {
                    Label("Ulubione", systemImage: "star.fill")
                }
                .tag(3)

            NewsView()
                .tabItem {
                    Label("Więcej", systemImage: "ellipsis")
                }
                .tag(4)
        }
        .tint(KomBydTheme.accentBlue)
    }
}
