//
//  RiskDetector.swift
//  Psychosocial  Analytics
//

import Foundation

enum RiskDetector {
    struct CategoryDefinition {
        let category: String
        let severity: String
        let keywords: [String]
    }

    static let categories: [CategoryDefinition] = [
        .init(category: "Self-Harm or Suicidal Ideation", severity: "critical",
              keywords: ["suicide", "suicidal", "kill myself", "end my life", "self harm", "self-harm", "cutting"]),
        .init(category: "Violence or Homicidal Ideation", severity: "critical",
              keywords: ["homicidal", "kill", "hurt them", "weapon", "stabbing", "shooting"]),
        .init(category: "Abuse or Safeguarding", severity: "high",
              keywords: ["abuse", "abused", "neglect", "domestic violence", "assault", "trafficking"]),
        .init(category: "Substance Relapse", severity: "high",
              keywords: ["relapse", "using again", "overdose", "withdrawal", "binge"]),
        .init(category: "Housing Instability", severity: "moderate",
              keywords: ["evicted", "eviction", "homeless", "unhoused", "no place to stay"])
    ]

    private static let negationCues: [String] = [
        "no ", "not ", "without ", "denies", "denied", "denying",
        "no concerns", "no current", "absent", "n/a"
    ]

    static func scan(payload: AssessmentPayload) -> [RiskNote] {
        var results: [RiskNote] = []
        for (sectionRaw, answers) in payload.sectionAnswers {
            let sectionTitle = AssessmentSection(rawValue: sectionRaw)?.title ?? sectionRaw
            for answer in answers where !answer.value.isEmpty {
                results.append(contentsOf: scan(text: answer.value, sectionTitle: sectionTitle))
            }
        }
        return results
    }

    private static func scan(text: String, sectionTitle: String) -> [RiskNote] {
        var notes: [RiskNote] = []
        let sentences = sentences(in: text)
        for sentence in sentences {
            let lower = sentence.lowercased()
            if negationCues.contains(where: { lower.contains($0) }) { continue }
            for category in categories {
                guard let matched = category.keywords.first(where: { wordMatch($0, in: lower) }) else { continue }
                notes.append(
                    RiskNote(
                        category: category.category,
                        severity: category.severity,
                        sourceSection: sectionTitle,
                        excerpt: excerpt(around: matched, in: sentence)
                    )
                )
            }
        }
        return notes
    }

    private static func wordMatch(_ keyword: String, in text: String) -> Bool {
        // Whole-word / phrase match. Pad with single space to allow boundary checks
        // even when the keyword sits at the very start or end of `text`.
        let padded = " " + text + " "
        let escaped = NSRegularExpression.escapedPattern(for: keyword)
        let pattern = "(^|[^a-z0-9])" + escaped + "([^a-z0-9]|$)"
        return padded.range(of: pattern, options: .regularExpression) != nil
    }

    private static func sentences(in text: String) -> [String] {
        text.components(separatedBy: CharacterSet(charactersIn: ".!?\n;"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func excerpt(around keyword: String, in text: String) -> String {
        let lower = text.lowercased()
        guard let range = lower.range(of: keyword) else { return text }
        let start = text.index(range.lowerBound, offsetBy: -40, limitedBy: text.startIndex) ?? text.startIndex
        let end = text.index(range.upperBound, offsetBy: 60, limitedBy: text.endIndex) ?? text.endIndex
        let prefix = start == text.startIndex ? "" : "…"
        let suffix = end == text.endIndex ? "" : "…"
        return prefix + String(text[start..<end]).trimmingCharacters(in: .whitespacesAndNewlines) + suffix
    }
}
