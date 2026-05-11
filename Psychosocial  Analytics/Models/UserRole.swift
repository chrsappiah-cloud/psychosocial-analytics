//
//  UserRole.swift
//  Psychosocial  Analytics
//

import Foundation

enum UserRole: String, Codable, CaseIterable {
    case socialWorker
    case client
    case admin

    var displayName: String {
        switch self {
        case .socialWorker: "Social Worker"
        case .client: "Client"
        case .admin: "Administrator"
        }
    }
}
