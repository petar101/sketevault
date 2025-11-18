import SwiftUI

struct MediaDetailView: View {
    let item: MediaItem
    var onDelete: (() -> Void)? = nil
    @EnvironmentObject var library: MediaLibrary
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var fullImage: UIImage?
    @State private var showDeleteConfirmation = false

    var body: some View {
        Group {
            ZStack {
                Color.black.ignoresSafeArea()

                if item.type == .photo {
                    if let fullImage = fullImage {
                        Image(uiImage: fullImage)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in scale = value }
                                    .onEnded { _ in
                                        withAnimation(.spring()) { scale = 1.0 }
                                    }
                            )
                    } else {
                        ProgressView()
                            .tint(.white)
                            .controlSize(.large)
                    }
                } else {
                    // Video player would go here
                    Text("Video playback not implemented")
                        .foregroundColor(.white)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Delete Photo", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                library.deleteItem(item)
                onDelete?()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this photo?")
        }
        .onAppear {
            loadFullImage()
        }
    }
    
    private func loadFullImage() {
        if item.type == .photo {
            if let data = try? Data(contentsOf: item.fileURL),
               let loadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.fullImage = loadedImage
                }
            }
        }
    }
}

