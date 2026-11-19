import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            StopsView()
                .tabItem {
                    Label("Przystanki", systemImage: "clock.arrow.circlepath")
                }

            LinesView()
                .tabItem {
                    Label("Linie", systemImage: "tram.fill")
                }

            NewsView()
                .tabItem {
                    Label("Komunikaty", systemImage: "newspaper.fill")
                }
        }
    }
}
