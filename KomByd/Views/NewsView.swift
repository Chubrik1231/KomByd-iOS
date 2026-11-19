import SwiftUI

struct NewsView: View {
    @State private var news: [NewsItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
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
                } else if news.isEmpty {
                    Text("Brak aktywnych komunikatów ZDMiKP")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(news) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.cleanTitle)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text(item.cleanDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Komunikaty")
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
            self.errorMessage = "Nie udało się pobrać komunikatów: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
