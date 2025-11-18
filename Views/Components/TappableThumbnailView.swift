import SwiftUI

struct TappableThumbnailView: View {
    let item: MediaItem
    let onDelete: (() -> Void)?
    @Binding var isSelectionMode: Bool
    @Binding var selectedItems: Set<UUID>
    
    var body: some View {
        NavigationLink {
            MediaDetailView(item: item, onDelete: onDelete)
        } label: {
            MediaThumbnailView(item: item)
        }
        .buttonStyle(.plain)
    }
}

