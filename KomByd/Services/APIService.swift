import Foundation

class APIService {
    static let shared = APIService()
    private init() {}

    private let userAgent = "KomByd/2.2.1"
    private let departuresKey = "OYXBCyGf8baw9gmIOW9aPGMotYNSdfa5aXt5fLNSrmo6qcR6WHvKQQ=="
    private let newsKey = "5yOSZJfKZxIFAf1jTLAUM/Ibd0JExfkY0YSAe8CaAXCbvHNIYUWUaQ=="

    // MARK: - Pobieranie listy przystanków (1200+ przystanków w Bydgoszczy)
    func fetchStops() async throws -> [Stop] {
        guard let url = URL(string: "https://kombyd.azurewebsites.net/ResourcesNew/lista_new.json") else {
            throw URLError(.badURL)
        }
        var req = URLRequest(url: url)
        req.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        let (data, _) = try await URLSession.shared.data(for: req)
        let stops = try JSONDecoder().decode([Stop].self, from: data)
        return stops
    }

    // MARK: - Pobieranie linii i tras
    func fetchLines() async throws -> [Line] {
        guard let url = URL(string: "https://kombyd.azurewebsites.net/ResourcesNew/linie_new.json") else {
            throw URLError(.badURL)
        }
        var req = URLRequest(url: url)
        req.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        let (data, _) = try await URLSession.shared.data(for: req)
        let lines = try JSONDecoder().decode([Line].self, from: data)
        return lines
    }

    // MARK: - Pobieranie odjazdów na żywo dla wybranego przystanku (live GPS)
    func fetchDepartures(oldStopNumber: String) async throws -> [Departure] {
        guard var components = URLComponents(string: "https://kombydfunc.azurewebsites.net/api/GetDepartures") else {
            throw URLError(.badURL)
        }
        components.queryItems = [
            URLQueryItem(name: "stop", value: oldStopNumber)
        ]
        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        req.setValue(departuresKey, forHTTPHeaderField: "x-functions-key")

        let (data, _) = try await URLSession.shared.data(for: req)
        let departures = try JSONDecoder().decode([Departure].self, from: data)
        return departures
    }

    // MARK: - Pobieranie komunikatów ZDMiKP
    func fetchNews() async throws -> [NewsItem] {
        guard let url = URL(string: "https://kombydfunc.azurewebsites.net/api/GetCommunicationNews") else {
            throw URLError(.badURL)
        }
        var req = URLRequest(url: url)
        req.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        req.setValue(newsKey, forHTTPHeaderField: "x-functions-key")

        let (data, _) = try await URLSession.shared.data(for: req)
        let news = try JSONDecoder().decode([NewsItem].self, from: data)
        return news
    }
}
