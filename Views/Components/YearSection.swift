import SwiftUI

struct YearSection: View {
    let year: Int
    let items: [MediaItem]
    let columns: [GridItem]
    var onDelete: (() -> Void)? = nil
    @Binding var isSelectionMode: Bool
    @Binding var selectedItems: Set<UUID>
    var onToggleSelection: (MediaItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(year, format: .number.grouping(.never))
                    .font(AppTypography.yearTitle)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(items.count)")
                    .font(AppTypography.photoCount)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(items.sorted(by: { $0.dateAdded > $1.dateAdded })) { item in
                    if isSelectionMode {
                        SelectableThumbnailView(
                            item: item,
                            isSelected: selectedItems.contains(item.id),
                            onTap: {
                                onToggleSelection(item)
                            }
                        )
                    } else {
                        TappableThumbnailView(
                            item: item,
                            onDelete: onDelete,
                            isSelectionMode: $isSelectionMode,
                            selectedItems: $selectedItems
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, AppSpacing.medium)
    }
}

