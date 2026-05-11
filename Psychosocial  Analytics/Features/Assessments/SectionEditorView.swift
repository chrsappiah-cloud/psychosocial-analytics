//
//  SectionEditorView.swift
//  Psychosocial  Analytics
//

import SwiftUI

struct SectionEditorView: View {
    let section: AssessmentSection
    @Binding var answers: [FieldAnswer]
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                Text(section.title)
                    .font(.title3.weight(.semibold))
                Text(section.group.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(answers.indices, id: \.self) { index in
                Section(header: Text(answers[index].label),
                        footer: Text(prompt(for: answers[index].key))
                            .font(.caption)
                            .foregroundStyle(.secondary)) {
                    fieldEditor(for: index)
                    if isRequired(answers[index].key) {
                        Label("Required", systemImage: "asterisk")
                            .font(.caption2)
                            .foregroundStyle(Color.royalGold)
                    }
                }
            }
        }
        .navigationTitle("Edit Section")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave()
                    dismiss()
                }
                .tint(.emeraldAction)
            }
        }
    }

    @ViewBuilder
    private func fieldEditor(for index: Int) -> some View {
        let kind = kind(for: answers[index].key)
        switch kind {
        case .shortText:
            TextField("", text: $answers[index].value)
                .textInputAutocapitalization(.sentences)
        case .longText:
            TextField("", text: $answers[index].value, axis: .vertical)
                .lineLimit(3...8)
                .textInputAutocapitalization(.sentences)
        case .date:
            DatePicker("",
                       selection: dateBinding(for: index),
                       displayedComponents: .date)
                .labelsHidden()
        case .number:
            TextField("", text: $answers[index].value)
                .keyboardType(.numberPad)
        case .choice(let options):
            Picker("", selection: $answers[index].value) {
                Text("Select…").tag("")
                ForEach(options, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.menu)
        }
    }

    private func dateBinding(for index: Int) -> Binding<Date> {
        Binding<Date>(
            get: {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withFullDate]
                return formatter.date(from: answers[index].value) ?? .now
            },
            set: { newValue in
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withFullDate]
                answers[index].value = formatter.string(from: newValue)
            }
        )
    }

    private func definition(for key: String) -> SectionFieldDefinition? {
        SectionTemplateLibrary.template(for: section).definitions.first { $0.key == key }
    }

    private func kind(for key: String) -> SectionFieldKind {
        definition(for: key)?.kind ?? .longText
    }

    private func prompt(for key: String) -> String {
        definition(for: key)?.prompt ?? ""
    }

    private func isRequired(_ key: String) -> Bool {
        definition(for: key)?.isRequired ?? false
    }
}
