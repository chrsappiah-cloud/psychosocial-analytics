import SwiftUI

public struct NewClientUploadView: View {
    @ObservedObject var uploadService: UploadService
    @State private var fullName = ""
    @State private var dateOfBirth = Date()
    @State private var riskLevel = 2
    @State private var notes = ""

    public init(uploadService: UploadService) { self.uploadService = uploadService }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PremiumTheme.cardStyle {
                    VStack(alignment: .leading, spacing: 14) {
                        BrandedSectionTitle(
                            "New client intake",
                            subtitle: "Creates client record and syncs to Supabase with iCloud backups"
                        )

                        TextField("Full name", text: $fullName)
                            .textFieldStyle(.roundedBorder)
                            .accessibilityIdentifier(AccessibilityID.fieldClientName)

                        DatePicker("Date of birth", selection: $dateOfBirth, displayedComponents: .date)
                            .foregroundStyle(PremiumTheme.textPrimary)

                        Stepper("Risk level: \(riskLevel)", value: $riskLevel, in: 1...5)
                            .accessibilityIdentifier(AccessibilityID.stepperClientRisk)

                        TextEditor(text: $notes)
                            .frame(minHeight: 90)
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .background(PremiumTheme.surface, in: RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(PremiumTheme.border))
                            .accessibilityIdentifier(AccessibilityID.fieldClientNotes)

                        Button {
                            Task { await saveClient() }
                        } label: {
                            Label("Save new client", systemImage: "person.badge.plus")
                        }
                        .psychosocialPrimaryButton()
                        .accessibilityIdentifier(AccessibilityID.buttonSaveNewClient)
                        .disabled(fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .padding(16)
        }
    }

    private func saveClient() async {
        let draft = NewClientDraft(
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            dateOfBirth: dateOfBirth,
            riskLevel: riskLevel,
            notes: notes
        )
        _ = try? await uploadService.saveNewClient(draft)
        fullName = ""
        notes = ""
        riskLevel = 2
    }
}
