//
//  AssessmentDraft.swift
//  Psychosocial  Analytics
//

import Foundation
import SwiftData

@Model
final class AssessmentDraft {
    var id: UUID
    var clientName: String
    var statusRaw: String
    var createdAt: Date
    var updatedAt: Date
    var payload: Data?

    init(
        id: UUID = UUID(),
        clientName: String,
        status: AssessmentStatus = .draft,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        payload: Data? = nil
    ) {
        self.id = id
        self.clientName = clientName
        self.statusRaw = status.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.payload = payload
    }

    var status: AssessmentStatus {
        get { AssessmentStatus(rawValue: statusRaw) ?? .draft }
        set { statusRaw = newValue.rawValue }
    }

    var assessmentPayload: AssessmentPayload {
        get {
            guard let payload, let decoded = try? JSONDecoder().decode(AssessmentPayload.self, from: payload) else {
                return .empty
            }
            return decoded
        }
        set {
            payload = (try? JSONEncoder().encode(newValue)) ?? Data()
            updatedAt = .now
        }
    }

    func answers(for section: AssessmentSection) -> [FieldAnswer] {
        assessmentPayload.answers(for: section)
    }

    func setAnswers(_ answers: [FieldAnswer], for section: AssessmentSection) {
        var p = assessmentPayload
        p.setAnswers(answers, for: section)
        assessmentPayload = p
    }

    func storeReport(_ report: AssessmentReport, riskFlags: [RiskFlag] = []) {
        var p = assessmentPayload
        p.report = report
        if !riskFlags.isEmpty { p.riskFlags = riskFlags }
        assessmentPayload = p
        status = .inReview
    }
}
