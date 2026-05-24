import Foundation

public enum MediaKind: String, Codable, CaseIterable, Sendable {
    case text, audio, video, image, document, pdf, archive, other

    public var displayName: String {
        switch self {
        case .text: return "Text"
        case .audio: return "Audio"
        case .video: return "Video"
        case .image: return "Image"
        case .document: return "Document"
        case .pdf: return "PDF"
        case .archive: return "Archive"
        case .other: return "Other"
        }
    }
}

public enum UploadSource: String, Codable, Sendable {
    case manualFile
    case externalURL
    case camera
    case photoLibrary
    case microphone
    case pasteboard
}

public enum UploadStatus: String, Codable, Sendable {
    case pending, uploading, synced, failed
}

public struct MediaUpload: Identifiable, Codable, Sendable {
    public let id: UUID
    public var clientID: UUID?
    public var fileName: String
    public var mimeType: String
    public var kind: MediaKind
    public var source: UploadSource
    public var localPath: String?
    public var remoteURL: String?
    public var externalSourceURL: String?
    public var byteSize: Int64
    public var status: UploadStatus
    public var createdAt: Date
    public var errorMessage: String?

    public init(
        id: UUID = UUID(),
        clientID: UUID? = nil,
        fileName: String,
        mimeType: String,
        kind: MediaKind,
        source: UploadSource,
        localPath: String? = nil,
        remoteURL: String? = nil,
        externalSourceURL: String? = nil,
        byteSize: Int64 = 0,
        status: UploadStatus = .pending,
        createdAt: Date = Date(),
        errorMessage: String? = nil
    ) {
        self.id = id
        self.clientID = clientID
        self.fileName = fileName
        self.mimeType = mimeType
        self.kind = kind
        self.source = source
        self.localPath = localPath
        self.remoteURL = remoteURL
        self.externalSourceURL = externalSourceURL
        self.byteSize = byteSize
        self.status = status
        self.createdAt = createdAt
        self.errorMessage = errorMessage
    }
}

public struct NewClientDraft: Identifiable, Codable, Sendable {
    public let id: UUID
    public var fullName: String
    public var dateOfBirth: Date
    public var riskLevel: Int
    public var notes: String
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        fullName: String,
        dateOfBirth: Date = Date(),
        riskLevel: Int = 1,
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.fullName = fullName
        self.dateOfBirth = dateOfBirth
        self.riskLevel = riskLevel
        self.notes = notes
        self.createdAt = createdAt
    }
}
