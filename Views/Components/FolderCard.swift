import SwiftUI

struct FolderCard: View {
    let folder: Folder
    let itemCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .fill(Color.subtleAccent)
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "folder.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(Color.primaryAccent)
                }
                
                VStack(spacing: 4) {
                    Text(folder.name)
                        .font(AppTypography.folderName)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .frame(width: 100)
                    
                    Text("\(itemCount)")
                        .font(AppTypography.folderCount)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 120, height: 120)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

