import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var library: MediaLibrary
    @State private var showFileImporter = false
    @State private var selectedFolderId: UUID? = nil
    @State private var showCreateFolder = false
    @State private var newFolderName = ""
    @State private var isSelectionMode = false
    @State private var selectedItems: Set<UUID> = []
    @State private var showMoveToFolder = false
    @State private var showBatchDeleteConfirmation = false

    private let columns = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
    ]
    
    var currentFolder: Folder? {
        guard let selectedFolderId = selectedFolderId else { return nil }
        return library.folders.first { $0.id == selectedFolderId }
    }
    
    var itemsToShow: [MediaItem] {
        // Always show all photos in main view, filter by folder when viewing a folder
        if selectedFolderId == nil {
            return library.items // Show ALL photos regardless of folder
        } else {
            return library.itemsInFolder(selectedFolderId) // Filter to folder
        }
    }
    
    var itemsByYear: [Int: [MediaItem]] {
        // Group all photos by year in main view, or filter by folder
        if selectedFolderId == nil {
            return library.itemsGroupedByYear(folderId: nil) // All photos
        } else {
            return library.itemsGroupedByYear(folderId: selectedFolderId) // Folder photos
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if selectedFolderId == nil {
                    mainView
                } else {
                    folderView
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if selectedFolderId == nil {
                        HStack(spacing: 10) {
                            AppLogo()
                            Text("Skete Vault")
                                .font(AppTypography.title)
                                .foregroundColor(.primary)
                        }
                    } else {
                        Text(currentFolder?.name ?? "Album")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if selectedFolderId != nil {
                        Button {
                            withAnimation(.spring()) {
                                selectedFolderId = nil
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if isSelectionMode {
                        selectionModeToolbar
                    } else {
                        normalModeToolbar
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
                    .textInputAutocapitalization(.words)
                Button("Create") {
                    if !newFolderName.isEmpty {
                        library.createFolder(name: newFolderName)
                        newFolderName = ""
                    }
                }
                .buttonStyle(.borderedProminent)
                Button("Cancel", role: .cancel) {
                    newFolderName = ""
                }
            } message: {
                Text("Enter a name for the new folder")
            }
            .sheet(isPresented: $showMoveToFolder) {
                MoveToFolderSheet(
                    selectedItems: selectedItems,
                    currentFolderId: selectedFolderId,
                    onMove: { folderId in
                        moveSelectedItems(to: folderId)
                    }
                )
            }
            .alert("Delete Photos", isPresented: $showBatchDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteSelectedItems()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete \(selectedItems.count) photo\(selectedItems.count == 1 ? "" : "s")? This cannot be undone.")
            }
        }
    }
    
    // MARK: - Toolbar Views
    
    @ViewBuilder
    private var selectionModeToolbar: some View {
        Menu {
            Button {
                selectAll()
            } label: {
                Label("Select All", systemImage: "checkmark.circle.fill")
            }
            
            Button {
                invertSelection()
            } label: {
                Label("Invert Selection", systemImage: "arrow.triangle.2.circlepath")
            }
            
            if !selectedItems.isEmpty {
                Divider()
                
                Button(role: .destructive) {
                    showBatchDeleteConfirmation = true
                } label: {
                    Label("Delete \(selectedItems.count) Photo\(selectedItems.count == 1 ? "" : "s")", systemImage: "trash")
                }
                
                Button {
                    showMoveToFolder = true
                } label: {
                    Label("Add to Album", systemImage: "folder.badge.plus")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 18))
                .foregroundColor(.accentColor)
        }
        
        if !selectedItems.isEmpty {
            Text("\(selectedItems.count)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.accentColor)
                .padding(.trailing, 4)
        }
        
        Button {
            withAnimation {
                isSelectionMode = false
                selectedItems.removeAll()
            }
        } label: {
            Text("Done")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.accentColor)
        }
    }
    
    @ViewBuilder
    private var normalModeToolbar: some View {
        if selectedFolderId == nil {
            Button {
                showCreateFolder = true
            } label: {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 18))
                    .foregroundColor(.accentColor)
            }
        }
        
        Button {
            withAnimation {
                isSelectionMode = true
            }
        } label: {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 18))
                .foregroundColor(.accentColor)
        }
        
        Button {
            showFileImporter = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.accentColor)
        }
    }
    
    // MARK: - Main Views
    
    var mainView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xLarge) {
                if !library.folders.isEmpty {
                    albumsSection
                }
                
                if !itemsToShow.isEmpty {
                    photosByYearSection
                } else if library.folders.isEmpty {
                    emptyStateView
                }
            }
            .padding(.vertical, AppSpacing.medium)
        }
        .background(Color.appBackground)
    }
    
    var folderView: some View {
        ScrollView {
            if itemsToShow.isEmpty {
                emptyFolderView
            } else {
                photosByYearSection
            }
        }
        .background(Color.appBackground)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var albumsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Albums")
                .font(AppTypography.sectionTitle)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.large) {
                    ForEach(library.folders) { folder in
                        FolderCard(folder: folder, itemCount: library.itemsInFolder(folder.id).count) {
                            withAnimation(.spring()) {
                                selectedFolderId = folder.id
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, AppSpacing.medium)
    }
    
    @ViewBuilder
    private var photosByYearSection: some View {
        let sortedYears = itemsByYear.keys.sorted(by: >)
        ForEach(sortedYears, id: \.self) { year in
            YearSection(
                year: year,
                items: itemsByYear[year] ?? [],
                columns: columns,
                onDelete: {
                    selectedFolderId = nil
                },
                isSelectionMode: $isSelectionMode,
                selectedItems: $selectedItems,
                onToggleSelection: { item in
                    toggleSelection(for: item)
                }
            )
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.stack")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Photos")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Tap + to import photos")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 80)
    }
    
    @ViewBuilder
    private var emptyFolderView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("Empty Album")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Add photos to this album")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 80)
    }
    
    // MARK: - Actions
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                guard url.startAccessingSecurityScopedResource() else {
                    print("Failed to access security-scoped resource")
                    continue
                }
                defer { url.stopAccessingSecurityScopedResource() }
                
                let fileExtension = url.pathExtension.lowercased()
                if fileExtension == "mov" || fileExtension == "mp4" || fileExtension == "m4v" || fileExtension == "avi" {
                    library.importVideo(from: url, folderId: selectedFolderId)
                } else {
                    library.importImage(from: url, folderId: selectedFolderId)
                }
            }
        case .failure(let error):
            print("Failed to import files: \(error)")
        }
    }
    
    private func moveSelectedItems(to folderId: UUID?) {
        let itemsToMove = library.items.filter { selectedItems.contains($0.id) }
        
        if let folderId = folderId {
            library.addItemsToFolder(itemsToMove, folderId: folderId)
        } else {
            if let currentFolderId = selectedFolderId {
                library.removeItemsFromFolder(itemsToMove, folderId: currentFolderId)
            }
        }
        
        withAnimation {
            selectedItems.removeAll()
            isSelectionMode = false
        }
    }
    
    private func toggleSelection(for item: MediaItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }
    
    private func selectAll() {
        selectedItems = Set(itemsToShow.map { $0.id })
    }
    
    private func invertSelection() {
        let allIds = Set(itemsToShow.map { $0.id })
        selectedItems = allIds.subtracting(selectedItems)
    }
    
    private func deleteSelectedItems() {
        let itemsToDelete = library.items.filter { selectedItems.contains($0.id) }
        library.deleteItems(itemsToDelete)
        withAnimation {
            selectedItems.removeAll()
            isSelectionMode = false
        }
    }
}

