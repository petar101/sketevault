import SwiftUI
import Combine   // <- this is important

enum MediaType {
    case photo
    case video
}

struct MediaItem: Identifiable {
    let id = UUID()
    let title: String
    let type: MediaType
    let thumbnailName: String
    let fullImageName: String
}

final class MediaLibrary: ObservableObject {
    @Published var items: [MediaItem] = []

    init() {
        loadSampleData()
    }

    private func loadSampleData() {
        items = [
            MediaItem(
                title: "Sample Photo",
                type: .photo,
                thumbnailName: "samplePhoto",
                fullImageName: "samplePhoto"
            )
        ]
    }
}
