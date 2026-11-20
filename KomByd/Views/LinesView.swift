import SwiftUI

struct LinesView: View {
    @State private var lines: [Line] = []
    @State private var allStops: [Stop] = []
    @State private var selectedCategory: Int = 0
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var trams: [Line] {
        lines.filter { $0.isTram || (Int($0.numerlinii) ?? 99) <= 12 }
    }

    private var dayBuses: [Line] {
        lines.filter { !$0.isTram && !$0.isNight && (Int($0.numerlinii) ?? 0) > 12 }
    }

    private var nightBuses: [Line] {
        lines.filter { $0.isNight }
    }

    private var displayedLines: [Line] {
        switch selectedCategory {
        case 0: return trams
        case 1: return dayBuses
        case 2: return nightBuses
        default: return lines
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Kategoria linii", selection: $selectedCategory) {
                    Text("Tramwaje (\(trams.count))").tag(0)
                    Text("Autobusy (\(dayBuses.count))").tag(1)
                    Text("Nocne (\(nightBuses.count))").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                List {
                    if isLoading && lines.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView("Pobieranie rozkładów...")
                            Spacer()
                        }
                        .padding()
                    } else if let error = errorMessage {
                        VStack(spacing: 8) {
                            Text(error).foregroundColor(.red)
                            Button("Spróbuj ponownie") {
                                Task { await loadData() }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(displayedLines) { line in
                            NavigationLink(destination: LineDetailView(line: line, allStops: allStops)) {
                                LineRowItem(line: line)
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Rozkład jazdy")
            .refreshable {
                await loadData()
            }
            .task {
                if lines.isEmpty || allStops.isEmpty {
                    await loadData()
                }
            }
        }
    }

    private func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            async let fetchL = APIService.shared.fetchLines()
            async let fetchS = APIService.shared.fetchStops()
            let (linesRes, stopsRes) = try await (fetchL, fetchS)
            self.lines = linesRes
            self.allStops = stopsRes
        } catch {
            self.errorMessage = "Błąd pobierania danych: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

struct LineRowItem: View {
    let line: Line

    var directionsSummary: String {
        guard let dirs = line.kierunki, !dirs.isEmpty else { return "" }
        return dirs.map { $0.displayDirection }.joined(separator: " ⇄ ")
    }

    var body: some View {
        HStack(spacing: 14) {
            LineBadge(lineNumber: line.numerlinii, isTram: line.isTram)
            VStack(alignment: .leading, spacing: 3) {
                Text("Linia \(line.numerlinii)")
                    .font(.system(size: 16, weight: .bold))
                if !directionsSummary.isEmpty {
                    Text(directionsSummary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

// MARK: - Szczegóły trasy linii ze wszystkimi przystankami
struct LineDetailView: View {
    let line: Line
    var allStops: [Stop] = []

    var body: some View {
        List {
            if let dirs = line.kierunki {
                ForEach(dirs) { dir in
                    Section(header: Text("Kierunek: \(dir.displayDirection)").font(.subheadline.bold())) {
                        if let stops = dir.przystanki {
                            ForEach(Array(stops.enumerated()), id: \.offset) { index, lineStop in
                                let matchedStop = allStops.first(where: { $0.numer == lineStop.id }) ??
                                    Stop(numer: lineStop.id, starynumer: lineStop.id, name: lineStop.displayName, direction: dir.displayDirection)

                                // Kliknięcie w przystanek otwiera odjazdy z filtrem na tę linię!
                                NavigationLink(destination: StopDetailView(stop: matchedStop, initialFilterLine: line.numerlinii)) {
                                    HStack(spacing: 14) {
                                        Text("\(index + 1)")
                                            .font(.caption.bold())
                                            .foregroundColor(.secondary)
                                            .frame(width: 28, height: 28)
                                            .background(Color(UIColor.tertiarySystemGroupedBackground))
                                            .clipShape(Circle())

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(lineStop.displayName)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.primary)

                                            HStack(spacing: 4) {
                                                Circle()
                                                    .fill(KomBydTheme.liveGreen)
                                                    .frame(width: 6, height: 6)
                                                Text("Zobacz odjazdy GPS linii \(line.numerlinii)")
                                                    .font(.caption)
                                                    .foregroundColor(KomBydTheme.accentBlue)
                                            }
                                        }

                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                    .contentShape(Rectangle())
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Linia \(line.numerlinii)")
    }
}
