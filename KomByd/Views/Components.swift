import SwiftUI

// MARK: - Kolorystyka KomByd
struct KomBydTheme {
    static let primaryNavy = Color(red: 0.10, green: 0.16, blue: 0.28)
    static let accentBlue = Color(red: 0.08, green: 0.45, blue: 0.85)
    static let tramRed = Color(red: 0.85, green: 0.18, blue: 0.18)
    static let busBlue = Color(red: 0.12, green: 0.44, blue: 0.78)
    static let nightPurple = Color(red: 0.38, green: 0.19, blue: 0.65)
    static let liveGreen = Color(red: 0.18, green: 0.68, blue: 0.29)
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
}

// MARK: - Znaczek linii (Badge)
struct LineBadge: View {
    let lineNumber: String
    var isTram: Bool = false

    var backgroundColor: Color {
        if isTram || (Int(lineNumber) ?? 99) <= 12 {
            return KomBydTheme.tramRed
        } else if lineNumber.uppercased().hasSuffix("N") {
            return KomBydTheme.nightPurple
        } else {
            return KomBydTheme.busBlue
        }
    }

    var body: some View {
        Text(lineNumber)
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(minWidth: 42)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .cornerRadius(8)
            .shadow(color: backgroundColor.opacity(0.3), radius: 2, y: 1)
    }
}

// MARK: - Przycisk na pulpicie (Dashboard Card)
struct DashboardButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(color)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(KomBydTheme.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Wiersz odjazdu na żywo
struct DepartureRowView: View {
    let departure: Departure

    var body: some View {
        HStack(spacing: 12) {
            LineBadge(lineNumber: departure.LineNumber, isTram: departure.isTram)

            VStack(alignment: .leading, spacing: 3) {
                Text(departure.displayDirection)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if let depot = departure.DepotDirection, !depot.isEmpty {
                    Text("Zjazd do: \(depot)")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text("Rozkład: \(departure.Hour)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(departure.formattedMinutes)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(departure.Minutes <= 2 ? KomBydTheme.liveGreen : KomBydTheme.accentBlue)

                HStack(spacing: 3) {
                    Circle()
                        .fill(KomBydTheme.liveGreen)
                        .frame(width: 6, height: 6)
                    Text("GPS na żywo")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
