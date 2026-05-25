import SwiftUI

public enum UploadSegment: String, CaseIterable, Identifiable {
    case files = "Files & Media"
    case url = "URL Import"
    case newClient = "New Client"

    public var id: String { rawValue }
}

public struct UploadHubView: View {
    @StateObject private var uploadService: UploadService
    @StateObject private var access = AccessControlService.shared
    @State private var segment: UploadSegment = .files

    public init() {
        _uploadService = StateObject(wrappedValue: UploadService())
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppBrandHeader(style: .compact, screenTitle: "Upload")

                Picker("Upload type", selection: $segment) {
                    ForEach(UploadSegment.allCases) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .accessibilityIdentifier(AccessibilityID.uploadSegmentPicker)

                Group {
                    switch segment {
                    case .files: DataUploadView(uploadService: uploadService)
                    case .url: URLImportView(uploadService: uploadService)
                    case .newClient: NewClientUploadView(uploadService: uploadService)
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .toolbar(.hidden, for: .navigationBar)
            .accessibilityIdentifier(AccessibilityID.screenUpload)
            .psychosocialScreen()
            .overlay(alignment: .bottom) {
                if !access.can(.uploadMedia) {
                    accessBanner
                }
            }
            .onAppear {
                if let index = UserDefaults.standard.object(forKey: "uitest_upload_segment") as? Int,
                   UploadSegment.allCases.indices.contains(index) {
                    segment = UploadSegment.allCases[index]
                    UserDefaults.standard.removeObject(forKey: "uitest_upload_segment")
                }
            }
        }
    }

    private var accessBanner: some View {
        Text("Upgrade your subscription to upload media and import URLs.")
            .font(.caption.weight(.medium))
            .foregroundStyle(PremiumTheme.textPrimary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(PremiumTheme.warning.opacity(0.9))
    }
}
