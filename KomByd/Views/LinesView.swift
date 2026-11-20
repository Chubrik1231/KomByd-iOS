import SwiftUI

struct LinesView: View {
    @State private var lines: [Line] = []
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
                                Task { await loadLines() }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(displayedLines) { line in
                            NavigationLink(destination: LineDetailView(line: line)) {
                                LineRowItem(line: line)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Rozkład jazdy")
            .refreshable {
                await loadLines()
            }
            .task {
                if lines.isEmpty {
                    await loadLines()
                }
            }
        }
    }

    private func loadLines() async {
        isLoading = true
        errorMessage = nil
        do {
            let res = try await APIService.shared.fetchLines()
            self.lines = res
        } catch {
            self.errorMessage = "Błąd: \(error.localizedDescription)"
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
        HStack(spacing: 12) {
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
        .padding(.vertical, 3)
    }
}

struct LineDetailView: View {
    let line: Line

    var body: some View {
        List {
            if let dirs = line.kierunki {
                ForEach(dirs) { dir in
                    Section(header: Text("Kierunek: \(dir.displayDirection)").font(.subheadline.bold())) {
                        if let stops = dir.przystanki {
                            ForEach(Array(stops.enumerated()), id: \.offset) { index, stop in
                                HStack(spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.caption.bold())
                                        .foregroundColor(.secondary)
                                        .frame(width: 24, height: 24)
                                        .background(Color(UIColor.tertiarySystemGroupedBackground))
                                        .clipShape(Circle())
                                    Text(stop.displayName)
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Linia \(line.numerlinii)")
    }
}
