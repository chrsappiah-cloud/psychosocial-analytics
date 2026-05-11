//
//  Psychosocial__AnalyticsApp.swift
//  Psychosocial  Analytics
//
//  Created by Christopher Appiah-Thompson  on 12/5/2026.
//

import SwiftUI
import SwiftData
import UIKit

@main
struct Psychosocial__AnalyticsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AssessmentDraft.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.environment["PSA_DEMO_REPORT"] == "1" {
                DemoReportRoot()
            } else {
                RootShellView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

private struct DemoReportRoot: View {
    @State private var report: AssessmentReport?

    var body: some View {
        NavigationStack {
            Group {
                if let report {
                    ReportPreviewView(report: report)
                } else {
                    ProgressView("Generating sample draft report…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.pearlBackground.ignoresSafeArea())
                }
            }
        }
        .task {
            if report == nil {
                let draft = SampleAssessmentData.seededDraft()
                let generator = LocalDeterministicReportGenerator()
                let r = try? await generator.generate(from: draft)
                report = r
                if let r { exportFullPagePNG(report: r); exportJSON(report: r) }
            }
        }
    }

    @MainActor
    private func exportFullPagePNG(report: AssessmentReport) {
        let view = ReportPreviewView(report: report)
            .renderableContent
            .frame(width: 393)
            .background(Color.pearlBackground)
            .environment(\.colorScheme, .light)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        guard let cg = renderer.cgImage,
              let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return }
        let url = docs.appendingPathComponent("demo-report-fullpage.png")
        let image = UIImage(cgImage: cg)
        if let data = image.pngData() { try? data.write(to: url) }
    }

    private func exportJSON(report: AssessmentReport) {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let url = docs.appendingPathComponent("demo-report.json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(report) { try? data.write(to: url) }
    }
}
