import Foundation

// MARK: - Przystanek (Stop)
struct Stop: Identifiable, Codable, Hashable {
    var id: String { numer }
    let nazwa: String
    let numer: String
    let starynumer: String
    let kierunek: String?

    var displayName: String {
        nazwa.decodingHTMLEntities()
    }

    var cleanDirection: String {
        (kierunek ?? "").decodingHTMLEntities()
    }
}

// MARK: - Linia (Line)
struct Line: Identifiable, Codable {
    var id: String { numerlinii }
    let numerlinii: String
    let typ: String?
    let kierunki: [LineDirection]?

    var isTram: Bool {
        typ?.uppercased() == "T"
    }

    var isNight: Bool {
        numerlinii.uppercased().hasSuffix("N")
    }
}

struct LineDirection: Identifiable, Codable {
    var id: String { kierunek }
    let kierunek: String
    let przystanki: [LineStop]?

    var displayDirection: String {
        kierunek.decodingHTMLEntities()
    }
}

struct LineStop: Identifiable, Codable {
    let id: String
    let nazwa: String

    var displayName: String {
        nazwa.decodingHTMLEntities()
    }
}

// MARK: - Odjazd w czasie rzeczywistym (Departure)
struct Departure: Identifiable, Codable {
    var id: String { "\(LineNumber)-\(Hour)-\(Minutes)-\(Direction)" }
    let LineNumber: String
    let Hour: String
    let Minutes: Int
    let Direction: String
    let DepotDirection: String?
    let VehicleType: Int?
    let IsDepot: Bool?

    var displayDirection: String {
        Direction.decodingHTMLEntities()
    }

    var formattedMinutes: String {
        if Minutes <= 0 {
            return "teraz"
        } else {
            return "\(Minutes) min"
        }
    }
}

// MARK: - Komunikat (News)
struct NewsItem: Identifiable, Codable {
    var id: String { title }
    let title: String
    let description: String

    var cleanDescription: String {
        description
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .decodingHTMLEntities()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var cleanTitle: String {
        title.decodingHTMLEntities()
    }
}
