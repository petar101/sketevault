import SwiftUI

struct SelectableThumbnailView: View {
    let item: MediaItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                MediaThumbnailView(item: item)
                
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.accentColor : Color(.systemBackground))
                        .frame(width: 24, height: 24)
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    } else {
                        Circle()
                            .stroke(Color(.systemGray3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(8)
            }
        }
        .buttonStyle(.plain)
    }
}

