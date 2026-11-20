import Foundation
import CoreLocation

// MARK: - Przystanek (Stop)
struct Stop: Identifiable, Codable, Hashable {
    var id: String { numer }
    let rawNazwa: String
    let numer: String
    let starynumer: String
    let rawKierunek: String?
    let lat: String?
    let lng: String?

    let displayName: String
    let cleanDirection: String

    var coordinate: CLLocationCoordinate2D? {
        guard let latStr = lat, let lngStr = lng,
              let latVal = Double(latStr), let lngVal = Double(lngStr),
              latVal != 0, lngVal != 0 else { return nil }
        return CLLocationCoordinate2D(latitude: latVal, longitude: lngVal)
    }

    enum CodingKeys: String, CodingKey {
        case rawNazwa = "nazwa"
        case numer
        case starynumer
        case rawKierunek = "kierunek"
        case lat
        case lng
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rawNazwa = try container.decode(String.self, forKey: .rawNazwa)
        self.numer = try container.decode(String.self, forKey: .numer)
        self.starynumer = try container.decode(String.self, forKey: .starynumer)
        self.rawKierunek = try container.decodeIfPresent(String.self, forKey: .rawKierunek)
        self.lat = try container.decodeIfPresent(String.self, forKey: .lat)
        self.lng = try container.decodeIfPresent(String.self, forKey: .lng)

        // Декодируем один раз при загрузке данных
        self.displayName = self.rawNazwa.decodingHTMLEntities()
        self.cleanDirection = (self.rawKierunek ?? "").decodingHTMLEntities()
    }

    // Для инициализации вручную и резервных вариантов
    init(numer: String, starynumer: String, name: String, direction: String?, lat: String? = nil, lng: String? = nil) {
        self.numer = numer
        self.starynumer = starynumer
        self.rawNazwa = name
        self.rawKierunek = direction
        self.lat = lat
        self.lng = lng
        self.displayName = name
        self.cleanDirection = direction ?? ""
    }
}

// MARK: - Linia (Line)
struct Line: Identifiable, Codable {
    var id: String { numerlinii }
    let numerlinii: String
    let typ: String?
    let kierunki: [LineDirection]?

    var isTram: Bool {
        typ?.uppercased() == "T" || (Int(numerlinii) ?? 99) <= 12
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

// MARK: - Odjazd na żywo (Live Departure)
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

    var isTram: Bool {
        (Int(LineNumber) ?? 99) <= 12
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

    var cleanTitle: String {
        title.decodingHTMLEntities()
    }

    var cleanDescription: String {
        description
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .decodingHTMLEntities()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Bilet Okresowy (Periodic Ticket)
struct PeriodicTicket: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var lineNumber: String
    var expiryDate: Date

    var isAllLines: Bool {
        lineNumber.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var daysRemaining: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfExpiry = calendar.startOfDay(for: expiryDate)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfExpiry)
        return max(0, components.day ?? 0)
    }

    var isExpired: Bool {
        expiryDate < Date()
    }
}
