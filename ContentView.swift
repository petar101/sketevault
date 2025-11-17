import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var library: MediaLibrary
    @State private var showFileImporter = false
    @State private var selectedFolderId: UUID? = nil
    @State private var showCreateFolder = false
    @State private var newFolderName = ""

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var currentFolder: Folder? {
        guard let selectedFolderId = selectedFolderId else { return nil }
        return library.folders.first { $0.id == selectedFolderId }
    }
    
    var itemsToShow: [MediaItem] {
        library.itemsInFolder(selectedFolderId)
    }
    
    var itemsByYear: [Int: [MediaItem]] {
        library.itemsGroupedByYear(folderId: selectedFolderId)
    }

    var body: some View {
        NavigationStack {
            Group {
                if selectedFolderId == nil {
                    // Main view: show folders and all photos grouped by year
                    mainView
                } else {
                    // Folder view: show photos in selected folder grouped by year
                    folderView
                }
            }
            .navigationTitle(selectedFolderId == nil ? "Skete Vault" : (currentFolder?.name ?? "Folder"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if selectedFolderId != nil {
                        Button {
                            selectedFolderId = nil
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if selectedFolderId == nil {
                        Button {
                            showCreateFolder = true
                        } label: {
                            Image(systemName: "folder.badge.plus")
                        }
                    }
                    
                    Button {
                        showFileImporter = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.image, .movie],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }
            .alert("New Folder", isPresented: $showCreateFolder) {
                TextField("Folder Name", text: $newFolderName)
                Button("Create") {
                    if !newFolderName.isEmpty {
                        library.createFolder(name: newFolderName)
                        newFolderName = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    newFolderName = ""
                }
            } message: {
                Text("Enter a name for the new folder")
            }
        }
    }
    
    var mainView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Folders section
                if !library.folders.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Folders")
                            .font(.headline)
                            .padding(.horizontal, 4)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(library.folders) { folder in
                                    FolderCard(folder: folder, itemCount: library.itemsInFolder(folder.id).count) {
                                        selectedFolderId = folder.id
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
                
                // Photos grouped by year
                if !itemsToShow.isEmpty {
                    let sortedYears = itemsByYear.keys.sorted(by: >)
                    ForEach(sortedYears, id: \.self) { year in
                        YearSection(year: year, items: itemsByYear[year] ?? [], columns: columns)
                    }
                } else if library.folders.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Photos")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Tap the import button to add photos from Files, iCloud, or your computer.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    var folderView: some View {
        ScrollView {
            if itemsToShow.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "folder")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Folder is Empty")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Import photos to add them to this folder.")
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                let sortedYears = itemsByYear.keys.sorted(by: >)
                ForEach(sortedYears, id: \.self) { year in
                    YearSection(year: year, items: itemsByYear[year] ?? [], columns: columns)
                }
            }
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                // Start accessing the security-scoped resource
                guard url.startAccessingSecurityScopedResource() else {
                    print("Failed to access security-scoped resource")
                    continue
                }
                defer { url.stopAccessingSecurityScopedResource() }
                
                // Determine if it's an image or video based on file extension
                let fileExtension = url.pathExtension.lowercased()
                if fileExtension == "mov" || fileExtension == "mp4" || fileExtension == "m4v" || fileExtension == "avi" {
                    library.importVideo(from: url, folderId: selectedFolderId)
                } else {
                    // Import as image (preserves original format)
                    library.importImage(from: url, folderId: selectedFolderId)
                }
            }
        case .failure(let error):
            print("Failed to import files: \(error)")
        }
    }
}

struct FolderCard: View {
    let folder: Folder
    let itemCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text(folder.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .frame(width: 100)
                
                Text("\(itemCount) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct YearSection: View {
    let year: Int
    let items: [MediaItem]
    let columns: [GridItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(year)")
                .font(.headline)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(items.sorted(by: { $0.dateAdded > $1.dateAdded })) { item in
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
    }
}

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
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        ProgressView()
                    }
            }

            if item.type == .video {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white, .black.opacity(0.7))
                    .padding(4)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 6))
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
        let asset = AVAsset(url: url)
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

struct MediaDetailView: View {
    let item: MediaItem
    @EnvironmentObject var library: MediaLibrary
    @State private var scale: CGFloat = 1.0
    @State private var fullImage: UIImage?
    @State private var showDeleteConfirmation = false

    var body: some View {
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
                }
            } else {
                // Video player would go here
                Text("Video playback not implemented")
                    .foregroundColor(.white)
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
