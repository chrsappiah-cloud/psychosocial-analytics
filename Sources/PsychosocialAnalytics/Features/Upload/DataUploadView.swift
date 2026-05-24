import SwiftUI

public struct DataUploadView: View {
    @ObservedObject var uploadService: UploadService
    @State private var showDocumentPicker = false
    @State private var showPhotoPicker = false
    @State private var textPayload = ""
    @State private var textTitle = "clinical-note"

    public init(uploadService: UploadService) { self.uploadService = uploadService }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PremiumTheme.cardStyle {
                    VStack(alignment: .leading, spacing: 14) {
                        BrandedSectionTitle(
                            "Manual upload",
                            subtitle: "Text, audio, video, images, PDF, and documents"
                        )

                        uploadButton("Choose files", icon: "folder.fill", id: AccessibilityID.buttonPickFiles) {
                            showDocumentPicker = true
                        }
                        uploadButton("Photo & video library", icon: "photo.on.rectangle", id: AccessibilityID.buttonPickPhotos) {
                            showPhotoPicker = true
                        }

                        TextField("Note title", text: $textTitle)
                            .textFieldStyle(.roundedBorder)
                        TextEditor(text: $textPayload)
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .background(PremiumTheme.surface, in: RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(PremiumTheme.border))

                        Button("Upload text") {
                            Task {
                                try? await uploadService.uploadText(textPayload, title: textTitle)
                                textPayload = ""
                            }
                        }
                        .psychosocialPrimaryButton()
                        .accessibilityIdentifier(AccessibilityID.buttonUploadText)
                        .disabled(textPayload.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || uploadService.isUploading)
                    }
                }

                uploadHistorySection
            }
            .padding(16)
        }
        #if os(iOS)
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPickerView { urls in
                showDocumentPicker = false
                Task { await ingestURLs(urls, source: .manualFile) }
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView { urls in
                showPhotoPicker = false
                Task { await ingestURLs(urls, source: .photoLibrary) }
            }
        }
        #endif
    }

    private func uploadButton(_ title: String, icon: String, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .psychosocialSecondaryButton()
        .accessibilityIdentifier(id)
        .disabled(uploadService.isUploading)
    }

    private var uploadHistorySection: some View {
        PremiumTheme.cardStyle {
            VStack(alignment: .leading, spacing: 10) {
                BrandedSectionTitle("Recent uploads", subtitle: "\(uploadService.uploads.count) item(s)")
                if uploadService.uploads.isEmpty {
                    Text("No uploads yet.")
                        .foregroundStyle(PremiumTheme.textSecondary)
                } else {
                    ForEach(uploadService.uploads.prefix(8)) { item in
                        HStack {
                            Image(systemName: icon(for: item.kind))
                                .foregroundStyle(PremiumTheme.emerald)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.fileName).font(.subheadline.weight(.medium))
                                Text("\(item.kind.displayName) · \(item.status.rawValue.capitalized)")
                                    .font(.caption)
                                    .foregroundStyle(PremiumTheme.textSecondary)
                            }
                            Spacer()
                        }
                        if item.id != uploadService.uploads.prefix(8).last?.id {
                            Divider().overlay(PremiumTheme.border)
                        }
                    }
                }
            }
        }
    }

    private func icon(for kind: MediaKind) -> String {
        switch kind {
        case .audio: return "waveform"
        case .video: return "video.fill"
        case .image: return "photo.fill"
        case .text: return "doc.text"
        case .pdf: return "doc.richtext"
        default: return "doc.fill"
        }
    }

    private func ingestURLs(_ urls: [URL], source: UploadSource) async {
        for url in urls {
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            guard let data = try? Data(contentsOf: url) else { continue }
            let mime = mimeType(for: url)
            _ = try? await uploadService.uploadFile(
                data: data,
                fileName: url.lastPathComponent,
                mimeType: mime,
                source: source
            )
        }
    }

    private func mimeType(for url: URL) -> String {
        if let type = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType {
            return type.preferredMIMEType ?? "application/octet-stream"
        }
        return "application/octet-stream"
    }
}
