import SwiftUI

struct NewsView: View {
    @State private var news: [NewsItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Informacje o aplikacji")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("KomByd dla iOS")
                                .font(.headline)
                            Text("Wersja 2.2.1 • ZDMiKP Bydgoszcz")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "tram.fill")
                            .font(.title2)
                            .foregroundColor(KomBydTheme.accentBlue)
                    }
                    .padding(.vertical, 2)

                    Link(destination: URL(string: "https://odjazdy.zdmikp.bydgoszcz.pl")!) {
                        Label("Strona ZDMiKP Bydgoszcz", systemImage: "safari")
                    }
                }

                Section(header: Text("Komunikaty i zmiany tras")) {
                    if isLoading && news.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView("Pobieranie komunikatów...")
                            Spacer()
                        }
                        .padding()
                    } else if let error = errorMessage {
                        VStack(spacing: 8) {
                            Text(error).foregroundColor(.red)
                            Button("Spróbuj ponownie") {
                                Task { await loadNews() }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    } else if news.isEmpty {
                        Text("Brak aktywnych komunikatów")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(news) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.cleanTitle)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)

                                Text(item.cleanDescription)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .navigationTitle("Więcej")
            .refreshable {
                await loadNews()
            }
            .task {
                if news.isEmpty {
                    await loadNews()
                }
            }
        }
    }

    private func loadNews() async {
        isLoading = true
        errorMessage = nil
        do {
            let res = try await APIService.shared.fetchNews()
            self.news = res
        } catch {
            self.errorMessage = "Błąd: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
