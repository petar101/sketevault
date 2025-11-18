import SwiftUI
import AVFoundation

struct MediaThumbnailView: View {
    let item: MediaItem
    @State private var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, minHeight: 0)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                    .fill(Color(.systemGray5))
                    .overlay {
                        ProgressView()
                            .tint(.accentColor)
                    }
            }

            if item.type == .video {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(8)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        if item.type == .photo {
            if let data = try? Data(contentsOf: item.fileURL),
               let loadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
        } else if item.type == .video {
            // Generate thumbnail for video
            generateVideoThumbnail(from: item.fileURL)
        }
    }
    
    private func generateVideoThumbnail(from url: URL) {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 0, preferredTimescale: 1)
        
        Task {
            do {
                let cgImage = try await imageGenerator.image(at: time).image
                await MainActor.run {
                    self.image = UIImage(cgImage: cgImage)
                }
            } catch {
                print("Failed to generate video thumbnail: \(error)")
            }
        }
    }
}

