import SwiftUI

struct ContentView: View {
    @EnvironmentObject var library: MediaLibrary

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(library.items) { item in
                        NavigationLink {
                            MediaDetailView(item: item)
                        } label: {
                            MediaThumbnailView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
            }
            .navigationTitle("Skete Vault")
        }
    }
}

struct MediaThumbnailView: View {
    let item: MediaItem

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(item.thumbnailName)
                .resizable()
                .aspectRatio(3/4, contentMode: .fill)
                .clipped()

            if item.type == .video {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white, .black.opacity(0.7))
                    .padding(4)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct MediaDetailView: View {
    let item: MediaItem
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(item.fullImageName)
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
        }
    }
}
