import SwiftUI

public struct URLImportView: View {
    @ObservedObject var uploadService: UploadService
    @State private var urlString = "https://"
    @State private var clientIDText = ""

    public init(uploadService: UploadService) { self.uploadService = uploadService }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PremiumTheme.cardStyle {
                    VStack(alignment: .leading, spacing: 14) {
                        BrandedSectionTitle(
                            "External URL import",
                            subtitle: "Download text, audio, video, PDF, and documents from HTTPS links"
                        )

                        TextField("https://example.com/file.mp4", text: $urlString)
                            .textFieldStyle(.roundedBorder)
                            #if os(iOS)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            #endif
                            .accessibilityIdentifier(AccessibilityID.fieldImportURL)

                        TextField("Client ID (optional)", text: $clientIDText)
                            .textFieldStyle(.roundedBorder)
                            .accessibilityIdentifier(AccessibilityID.fieldClientID)

                        Button {
                            Task { await importURL() }
                        } label: {
                            Label(
                                uploadService.isUploading ? "Importing…" : "Import from URL",
                                systemImage: "link.badge.plus"
                            )
                        }
                        .psychosocialPrimaryButton()
                        .accessibilityIdentifier(AccessibilityID.buttonImportURL)
                        .disabled(uploadService.isUploading || !isValidURL(urlString))

                        Text("Supported: public HTTPS URLs returning text, audio, video, images, PDF, and archives.")
                            .font(.caption)
                            .foregroundStyle(PremiumTheme.textTertiary)
                    }
                }
            }
            .padding(16)
        }
    }

    private func importURL() async {
        let clientID = UUID(uuidString: clientIDText.trimmingCharacters(in: .whitespacesAndNewlines))
        _ = try? await uploadService.importFromExternalURL(urlString, clientID: clientID)
    }

    private func isValidURL(_ value: String) -> Bool {
        guard let url = URL(string: value.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = url.scheme?.lowercased() else { return false }
        return ["https", "http"].contains(scheme) && url.host != nil
    }
}
