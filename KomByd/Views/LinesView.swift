import SwiftUI

struct LinesView: View {
    @State private var lines: [Line] = []
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

    var body: some View {
        NavigationStack {
            List {
                if isLoading && lines.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView("Pobieranie linii...")
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
                } else {
                    if !trams.isEmpty {
                        Section("Tramwaje") {
                            ForEach(trams) { line in
                                NavigationLink(destination: LineDetailView(line: line)) {
                                    LineRowItem(line: line)
                                }
                            }
                        }
                    }

                    if !dayBuses.isEmpty {
                        Section("Autobusy miejskie") {
                            ForEach(dayBuses) { line in
                                NavigationLink(destination: LineDetailView(line: line)) {
                                    LineRowItem(line: line)
                                }
                            }
                        }
                    }

                    if !nightBuses.isEmpty {
                        Section("Linie nocne") {
                            ForEach(nightBuses) { line in
                                NavigationLink(destination: LineDetailView(line: line)) {
                                    LineRowItem(line: line)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Linie")
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
            self.errorMessage = "Nie udało się pobrać linii: \(error.localizedDescription)"
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
            VStack(alignment: .leading, spacing: 2) {
                Text("Linia \(line.numerlinii)")
                    .font(.system(size: 16, weight: .semibold))
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
                    Section(header: Text("Kierunek: \(dir.displayDirection)")) {
                        if let stops = dir.przystanki {
                            ForEach(Array(stops.enumerated()), id: \.offset) { index, stop in
                                HStack(spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.caption.bold())
                                        .frame(width: 24, height: 24)
                                        .background(Color.secondary.opacity(0.15))
                                        .clipShape(Circle())
                                    Text(stop.displayName)
                                        .font(.system(size: 15))
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
