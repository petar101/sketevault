import SwiftUI

struct MoveToFolderSheet: View {
    @EnvironmentObject var library: MediaLibrary
    @Environment(\.dismiss) private var dismiss
    let selectedItems: Set<UUID>
    let currentFolderId: UUID?
    let onMove: (UUID?) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                if currentFolderId != nil {
                    Section {
                        Button {
                            onMove(nil)
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "house.fill")
                                    .foregroundColor(Color.primaryAccent)
                                Text("Remove from Album")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                    }
                }
                
                if !library.folders.isEmpty {
                    Section("Add to Album") {
                        ForEach(library.folders) { folder in
                            Button {
                                onMove(folder.id)
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(Color.primaryAccent)
                                    Text(folder.name)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add to Album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

