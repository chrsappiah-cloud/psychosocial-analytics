import SwiftUI

public struct Client: Identifiable, Codable {
    public let id: UUID
    public var fullName: String
    public var dateOfBirth: Date
    public var riskLevel: Int

    public init(id: UUID = UUID(), fullName: String, dateOfBirth: Date, riskLevel: Int) {
        self.id = id
        self.fullName = fullName
        self.dateOfBirth = dateOfBirth
        self.riskLevel = riskLevel
    }
}

@MainActor
public class ClientsViewModel: ObservableObject {
    @Published public var clients: [Client] = []
    @Published public var searchText: String = ""

    private let uploadService: UploadService

    public init(uploadService: UploadService? = nil) {
        self.uploadService = uploadService ?? UploadService()
        reload()
    }

    public func reload() {
        let stored = (try? uploadService.loadClients()) ?? []
        if stored.isEmpty {
            clients = [
                Client(fullName: "Jane Doe", dateOfBirth: Date(timeIntervalSince1970: 0), riskLevel: 2),
                Client(fullName: "John Smith", dateOfBirth: Date(timeIntervalSince1970: 100_000_000), riskLevel: 4),
                Client(fullName: "Maria Garcia", dateOfBirth: Date(timeIntervalSince1970: 200_000_000), riskLevel: 1)
            ]
        } else {
            clients = stored
        }
    }

    public var filteredClients: [Client] {
        if searchText.isEmpty { return clients }
        return clients.filter { $0.fullName.localizedCaseInsensitiveContains(searchText) }
    }
}

public struct ClientsView: View {
    @StateObject private var viewModel: ClientsViewModel
    @ObservedObject private var coordinator = AppCoordinator.shared

    public init() {
        _viewModel = StateObject(wrappedValue: ClientsViewModel())
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppBrandHeader(style: .compact, screenTitle: "Clients")

                List(viewModel.filteredClients) { client in
                    PremiumListRow(
                        icon: "person.circle.fill",
                        title: client.fullName,
                        subtitle: riskLabel(for: client.riskLevel),
                        accent: client.riskLevel > 3 ? PremiumTheme.danger : PremiumTheme.emerald
                    )
                    .listRowBackground(PremiumTheme.surface)
                    .listRowSeparatorTint(PremiumTheme.border)
                }
                .psychosocialListChrome()
            }
            .searchable(text: $viewModel.searchText, prompt: "Search clients by name")
            .accessibilityIdentifier(AccessibilityID.searchClients)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        coordinator.activeTab = .upload
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                    .accessibilityLabel("Add new client")
                    .accessibilityIdentifier(AccessibilityID.buttonGoToNewClient)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.reload()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Refresh clients")
                }
            }
            .toolbarBackground(PremiumTheme.surface.opacity(0.95), for: .navigationBar)
            .accessibilityIdentifier(AccessibilityID.screenClients)
            .psychosocialScreen()
            .onAppear { viewModel.reload() }
        }
    }

    private func riskLabel(for level: Int) -> String {
        "Risk level \(level) of 5"
    }
}
