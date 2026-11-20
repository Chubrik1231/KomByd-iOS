import SwiftUI

struct TicketsView: View {
    @State private var tickets: [PeriodicTicket] = []
    @State private var isShowingAdd = false
    @State private var newName = "Bilet sieciowy"
    @State private var newLine = ""
    @State private var newDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()

    @AppStorage("saved_periodic_tickets") private var savedTicketsJson: String = ""

    var body: some View {
        List {
            if tickets.isEmpty {
                Section {
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "ticket")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        Text("Brak zapisanych biletów")
                            .font(.headline)
                        Text("Dodaj swój bilet okresowy (np. 30-dniowy lub semestralny), aby kontrolować jego ważność.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button(action: { isShowingAdd = true }) {
                            Label("Dodaj bilet", systemImage: "plus")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.orange)
                                .cornerRadius(10)
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            } else {
                Section(header: Text("Twoje bilety okresowe")) {
                    ForEach(tickets) { ticket in
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(ticket.isExpired ? Color.red.opacity(0.15) : Color.orange.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                VStack(spacing: 0) {
                                    Text("\(ticket.daysRemaining)")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(ticket.isExpired ? .red : .orange)
                                    Text("dni")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(ticket.isExpired ? .red : .secondary)
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(ticket.name)
                                    .font(.headline)
                                if ticket.isAllLines {
                                    Text("Wszystkie linie ZDMiKP")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Linia: \(ticket.lineNumber)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Text("Ważny do: \(ticket.expiryDate.formatted(date: .long, time: .omitted))")
                                    .font(.caption)
                                    .foregroundColor(ticket.isExpired ? .red : .secondary)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 6)
                    }
                    .onDelete(perform: deleteTicket)
                }
            }
        }
        .navigationTitle("Bilety okresowe")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isShowingAdd = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingAdd) {
            NavigationStack {
                Form {
                    Section("Dane biletu") {
                        TextField("Nazwa biletu (np. Miesięczny Uczniowski)", text: $newName)
                        TextField("Numer linii (zostaw puste dla całej sieci)", text: $newLine)
                            .keyboardType(.numberPad)
                        DatePicker("Ważny do", selection: $newDate, displayedComponents: .date)
                    }
                }
                .navigationTitle("Nowy bilet")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Anuluj") { isShowingAdd = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Zapisz") {
                            addTicket()
                            isShowingAdd = false
                        }
                        .bold()
                    }
                }
            }
        }
        .onAppear {
            loadTickets()
        }
    }

    private func addTicket() {
        let ticket = PeriodicTicket(name: newName, lineNumber: newLine, expiryDate: newDate)
        tickets.append(ticket)
        saveTickets()
    }

    private func deleteTicket(at offsets: IndexSet) {
        tickets.remove(atOffsets: offsets)
        saveTickets()
    }

    private func saveTickets() {
        if let data = try? JSONEncoder().encode(tickets) {
            savedTicketsJson = String(data: data, encoding: .utf8) ?? ""
        }
    }

    private func loadTickets() {
        guard !savedTicketsJson.isEmpty, let data = savedTicketsJson.data(using: .utf8) else { return }
        if let decoded = try? JSONDecoder().decode([PeriodicTicket].self, from: data) {
            self.tickets = decoded
        }
    }
}
