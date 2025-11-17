import SwiftUI
import Combine

enum MediaType: Codable {
    case photo
    case video
}

struct Folder: Identifiable, Codable {
    let id: UUID
    var name: String
    let dateCreated: Date
    
    init(id: UUID = UUID(), name: String, dateCreated: Date = Date()) {
        self.id = id
        self.name = name
        self.dateCreated = dateCreated
    }
}

struct MediaItem: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let type: MediaType
    let dateAdded: Date
    var folderId: UUID?
    
    var fileURL: URL {
        MediaLibrary.storageDirectory.appendingPathComponent(fileName)
    }
    
    var year: Int {
        Calendar.current.component(.year, from: dateAdded)
    }
}

final class MediaLibrary: ObservableObject {
    @Published var items: [MediaItem] = []
    @Published var folders: [Folder] = []
    
    static let storageDirectory: URL = {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let mediaDirectory = documentsPath.appendingPathComponent("Media", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: mediaDirectory, withIntermediateDirectories: true)
        
        return mediaDirectory
    }()
    
    private let itemsFileName = "mediaItems.json"
    private let foldersFileName = "folders.json"
    
    init() {
        loadFolders()
        loadItems()
    }
    
    private var itemsFileURL: URL {
        MediaLibrary.storageDirectory.appendingPathComponent(itemsFileName)
    }
    
    private var foldersFileURL: URL {
        MediaLibrary.storageDirectory.appendingPathComponent(foldersFileName)
    }
    
    func loadFolders() {
        guard let data = try? Data(contentsOf: foldersFileURL),
              let decoded = try? JSONDecoder().decode([Folder].self, from: data) else {
            folders = []
            return
        }
        folders = decoded
    }
    
    private func saveFolders() {
        guard let encoded = try? JSONEncoder().encode(folders) else { return }
        try? encoded.write(to: foldersFileURL)
    }
    
    func loadItems() {
        guard let data = try? Data(contentsOf: itemsFileURL),
              let decoded = try? JSONDecoder().decode([MediaItem].self, from: data) else {
            items = []
            return
        }
        
        // Filter out items whose files no longer exist
        items = decoded.filter { FileManager.default.fileExists(atPath: $0.fileURL.path) }
        
        // Save back in case some files were missing
        saveItems()
    }
    
    private func saveItems() {
        guard let encoded = try? JSONEncoder().encode(items) else { return }
        try? encoded.write(to: itemsFileURL)
    }
    
    func createFolder(name: String) {
        let newFolder = Folder(name: name)
        folders.append(newFolder)
        saveFolders()
    }
    
    func deleteFolder(_ folder: Folder) {
        // Move items out of folder (set folderId to nil)
        items = items.map { item in
            if item.folderId == folder.id {
                return MediaItem(
                    id: item.id,
                    fileName: item.fileName,
                    type: item.type,
                    dateAdded: item.dateAdded,
                    folderId: nil
                )
            }
            return item
        }
        folders.removeAll { $0.id == folder.id }
        saveFolders()
        saveItems()
    }
    
    func moveItem(_ item: MediaItem, toFolder folderId: UUID?) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = MediaItem(
                id: item.id,
                fileName: item.fileName,
                type: item.type,
                dateAdded: item.dateAdded,
                folderId: folderId
            )
            saveItems()
        }
    }
    
    func itemsInFolder(_ folderId: UUID?) -> [MediaItem] {
        items.filter { $0.folderId == folderId }
    }
    
    func itemsGroupedByYear(folderId: UUID? = nil) -> [Int: [MediaItem]] {
        let filteredItems = folderId == nil ? items : items.filter { $0.folderId == folderId }
        return Dictionary(grouping: filteredItems) { $0.year }
    }
    
    func importImage(_ image: UIImage, folderId: UUID? = nil) {
        let id = UUID()
        let fileName = "\(id.uuidString).jpg"
        let fileURL = MediaLibrary.storageDirectory.appendingPathComponent(fileName)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        do {
            try imageData.write(to: fileURL)
            
            let newItem = MediaItem(
                id: id,
                fileName: fileName,
                type: .photo,
                dateAdded: Date(),
                folderId: folderId
            )
            
            items.insert(newItem, at: 0) // Add to beginning
            saveItems()
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    func importImage(from sourceURL: URL, folderId: UUID? = nil) {
        let id = UUID()
        let sourceExtension = sourceURL.pathExtension.lowercased()
        let fileName = "\(id.uuidString).\(sourceExtension.isEmpty ? "jpg" : sourceExtension)"
        let destinationURL = MediaLibrary.storageDirectory.appendingPathComponent(fileName)
        
        do {
            // Copy the file to our storage directory
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            
            let newItem = MediaItem(
                id: id,
                fileName: fileName,
                type: .photo,
                dateAdded: Date(),
                folderId: folderId
            )
            
            items.insert(newItem, at: 0)
            saveItems()
        } catch {
            print("Failed to import image: \(error)")
        }
    }
    
    func importVideo(from sourceURL: URL, folderId: UUID? = nil) {
        let id = UUID()
        let fileExtension = sourceURL.pathExtension
        let fileName = "\(id.uuidString).\(fileExtension.isEmpty ? "mov" : fileExtension)"
        let destinationURL = MediaLibrary.storageDirectory.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            
            let newItem = MediaItem(
                id: id,
                fileName: fileName,
                type: .video,
                dateAdded: Date(),
                folderId: folderId
            )
            
            items.insert(newItem, at: 0)
            saveItems()
        } catch {
            print("Failed to import video: \(error)")
        }
    }
    
    func deleteItem(_ item: MediaItem) {
        // Remove file
        try? FileManager.default.removeItem(at: item.fileURL)
        
        // Remove from items
        items.removeAll { $0.id == item.id }
        saveItems()
    }
}
