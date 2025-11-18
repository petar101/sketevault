import Foundation

struct MediaItem: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let type: MediaType
    let dateAdded: Date
    var folderIds: [UUID]
    
    init(id: UUID = UUID(), fileName: String, type: MediaType, dateAdded: Date, folderIds: [UUID] = []) {
        self.id = id
        self.fileName = fileName
        self.type = type
        self.dateAdded = dateAdded
        self.folderIds = folderIds
    }
    
    var fileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let mediaDirectory = documentsPath.appendingPathComponent("Media", isDirectory: true)
        return mediaDirectory.appendingPathComponent(fileName)
    }
    
    var year: Int {
        Calendar.current.component(.year, from: dateAdded)
    }
    
    // Legacy support for migration
    private enum CodingKeys: String, CodingKey {
        case id, fileName, type, dateAdded, folderId, folderIds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        fileName = try container.decode(String.self, forKey: .fileName)
        type = try container.decode(MediaType.self, forKey: .type)
        dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        
        // Support both old (folderId) and new (folderIds) format
        if let folderIds = try? container.decode([UUID].self, forKey: .folderIds) {
            self.folderIds = folderIds
        } else {
            // Try to decode old format (single folderId)
            // decodeIfPresent returns UUID? - handle it properly
            do {
                if let folderId = try container.decodeIfPresent(UUID.self, forKey: .folderId) {
                    self.folderIds = [folderId]
                } else {
                    self.folderIds = []
                }
            } catch {
                self.folderIds = []
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(type, forKey: .type)
        try container.encode(dateAdded, forKey: .dateAdded)
        try container.encode(folderIds, forKey: .folderIds)
    }
}

