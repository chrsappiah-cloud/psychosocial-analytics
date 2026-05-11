//
//  AssessmentPayload.swift
//  Psychosocial  Analytics
//

import Foundation

struct AssessmentPayload: Codable, Hashable {
    var sectionAnswers: [String: [FieldAnswer]]
    var riskFlags: [RiskFlag]
    var report: AssessmentReport?

    init(
        sectionAnswers: [String: [FieldAnswer]] = [:],
        riskFlags: [RiskFlag] = [],
        report: AssessmentReport? = nil
    ) {
        self.sectionAnswers = sectionAnswers
        self.riskFlags = riskFlags
        self.report = report
    }

    static let empty = AssessmentPayload()
}

extension AssessmentPayload {
    func answers(for section: AssessmentSection) -> [FieldAnswer] {
        sectionAnswers[section.rawValue] ?? []
    }

    mutating func setAnswers(_ answers: [FieldAnswer], for section: AssessmentSection) {
        sectionAnswers[section.rawValue] = answers
    }

    var totalAnsweredFields: Int {
        sectionAnswers.values.reduce(0) { acc, list in
            acc + list.filter { !$0.value.isEmpty }.count
        }
    }
}
