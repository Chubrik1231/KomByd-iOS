import SwiftUI

struct LineBadge: View {
    let lineNumber: String
    var isTram: Bool = false

    var backgroundColor: Color {
        if isTram || (Int(lineNumber) ?? 99) <= 12 {
            return Color.red
        } else if lineNumber.hasSuffix("N") {
            return Color.purple
        } else {
            return Color.blue
        }
    }

    var body: some View {
        Text(lineNumber)
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .cornerRadius(8)
    }
}

struct DepartureRowView: View {
    let departure: Departure

    var body: some View {
        HStack(spacing: 12) {
            LineBadge(lineNumber: departure.LineNumber, isTram: (Int(departure.LineNumber) ?? 99) <= 12)

            VStack(alignment: .leading, spacing: 3) {
                Text(departure.displayDirection)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                if let depot = departure.DepotDirection, !depot.isEmpty {
                    Text("Zjazd: \(depot)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Rozkładowo: \(departure.Hour)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(departure.formattedMinutes)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(departure.Minutes <= 2 ? .green : .blue)

                HStack(spacing: 2) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("GPS na żywo")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
