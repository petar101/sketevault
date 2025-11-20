# Skete Vault

A SwiftUI-based iOS media management application that allows users to organize photos and videos into albums (folders) and view them chronologically by year.

## 📁 Project Structure

```text
sketevault/
├── Models/                    # Data models
│   ├── MediaItem.swift       # Core media item model with file metadata
│   ├── Folder.swift          # Album/folder model
│   └── MediaType.swift       # Enum for photo/video types
│
├── Services/                  # Business logic layer
│   └── MediaLibrary.swift    # Central service managing all media operations
│
├── Views/                     # UI layer
│   ├── ContentView.swift     # Main view controller
│   ├── Components/           # Reusable UI components
│   │   ├── AppLogo.swift
│   │   ├── FolderCard.swift
│   │   ├── MediaDetailView.swift
│   │   ├── MediaThumbnailView.swift
│   │   ├── SelectableThumbnailView.swift
│   │   ├── TappableThumbnailView.swift
│   │   └── YearSection.swift
│   └── Sheets/               # Modal sheets
│       └── MoveToFolderSheet.swift
│
├── Theme/                     # Design system
│   └── AppTheme.swift        # Colors, typography, spacing constants
│
├── Assets.xcassets/          # Image assets
│   ├── AppIcon.appiconset/   # App icon
│   └── AppLogo.imageset/     # App logo
│
└── SketeVaultApp.swift       # App entry point
```

## 🏗️ Architecture

### Architecture Pattern: **MVVM (Model-View-ViewModel)**

The app follows a clean MVVM architecture with clear separation of concerns:

- **Models**: Pure data structures (`MediaItem`, `Folder`, `MediaType`)
- **Services**: Business logic and data persistence (`MediaLibrary`)
- **Views**: SwiftUI views that observe state changes
- **Theme**: Centralized design system

### Data Flow

```text
User Action → View → MediaLibrary → File System
                ↓                      ↓
            State Update          JSON Persistence
                ↓
            UI Update (via @Published)
```

## 🔄 Application Flow

### 1. **App Initialization**

```text
SketeVaultApp (Entry Point)
    ↓
Creates MediaLibrary instance (@StateObject)
    ↓
Injects as EnvironmentObject to ContentView
    ↓
MediaLibrary.init() loads persisted data:
    - loadFolders() → Reads folders.json
    - loadItems() → Reads mediaItems.json
```

### 2. **Main View States**

The app has two primary view states managed by `selectedFolderId`:

- **Main View** (`selectedFolderId == nil`):
  - Shows all media items across all folders
  - Displays horizontal scrollable album cards
  - Groups photos by year in descending order
  - Toolbar: Create Folder, Selection Mode, Import

- **Folder View** (`selectedFolderId != nil`):
  - Shows only media items in the selected folder
  - Groups photos by year
  - Toolbar: Back button, Selection Mode, Import

### 3. **Media Import Flow**

```text
User taps "+" button
    ↓
Shows FileImporter (images + videos)
    ↓
User selects files
    ↓
handleFileImport() processes URLs
    ↓
For each file:
    - Determine type (image/video)
    - Copy to Documents/Media/ directory
    - Create MediaItem with metadata
    - Associate with current folder (if any)
    ↓
MediaLibrary.importImage() or importVideo()
    ↓
Saves to JSON (mediaItems.json)
    ↓
@Published items triggers UI update
```

### 4. **Folder Management Flow**

**Creating a Folder:**

```text
User taps folder icon
    ↓
Shows alert with text field
    ↓
MediaLibrary.createFolder(name:)
    ↓
Creates Folder model
    ↓
Saves to folders.json
    ↓
UI updates with new FolderCard
```

**Adding Items to Folder:**

```text
User enters selection mode
    ↓
Selects multiple items
    ↓
Taps "Add to Album" from menu
    ↓
Shows MoveToFolderSheet
    ↓
User selects folder
    ↓
MediaLibrary.addItemsToFolder()
    ↓
Updates MediaItem.folderIds array
    ↓
Saves to mediaItems.json
```

### 5. **Selection Mode Flow**

```text
User taps selection icon
    ↓
isSelectionMode = true
    ↓
Thumbnails switch to SelectableThumbnailView
    ↓
User taps items to select/deselect
    ↓
selectedItems Set<UUID> tracks selections
    ↓
Toolbar shows:
    - Menu (Select All, Invert, Delete, Add to Album)
    - Selection count
    - Done button
```

### 6. **Media Viewing Flow**

```text
User taps thumbnail
    ↓
NavigationLink to MediaDetailView
    ↓
Loads full-resolution image from fileURL
    ↓
Displays with pinch-to-zoom gesture
    ↓
User can delete from detail view
```

## 📊 Data Models

### MediaItem

- **Purpose**: Represents a single photo or video
- **Key Properties**:
  - `id: UUID` - Unique identifier
  - `fileName: String` - Stored filename
  - `type: MediaType` - Photo or video
  - `dateAdded: Date` - Import timestamp
  - `folderIds: [UUID]` - Multiple folder associations (many-to-many)
- **Computed Properties**:
  - `fileURL` - Full path to file in Documents/Media/
  - `year` - Extracted from dateAdded for grouping

### Folder

- **Purpose**: Represents an album/collection
- **Key Properties**:
  - `id: UUID` - Unique identifier
  - `name: String` - User-defined name
  - `dateCreated: Date` - Creation timestamp

### MediaType

- **Enum**: `.photo` or `.video`
- Used to determine rendering and behavior

## 🔧 Core Service MediaLibrary

The `MediaLibrary` class is the central service managing all media operations:

### Responsibilities

1. **Data Persistence**
   - Saves/loads `MediaItem` array to `mediaItems.json`
   - Saves/loads `Folder` array to `folders.json`
   - Location: `Documents/Media/`

2. **File Management**
   - Stores imported files in `Documents/Media/`
   - Generates unique filenames using UUIDs
   - Handles file deletion

3. **Folder Operations**
   - Create, delete folders
   - Add/remove items from folders
   - Query items by folder

4. **Media Import**
   - `importImage(from:)` - Copies image files
   - `importVideo(from:)` - Copies video files
   - `importImage(_:)` - Direct UIImage import

5. **Data Queries**
   - `itemsInFolder(_:)` - Filter items by folder
   - `itemsGroupedByYear(folderId:)` - Group by year for display

### Key Design Decisions

- **Many-to-Many Relationship**: Items can belong to multiple folders via `folderIds` array
- **File-Based Storage**: All media stored in app's Documents directory
- **JSON Persistence**: Simple, human-readable metadata storage
- **ObservableObject**: Uses `@Published` for reactive UI updates

## 🎨 UI Components

### ContentView

- **Main orchestrator** of the app
- Manages navigation state (`selectedFolderId`)
- Handles selection mode state
- Coordinates toolbar actions
- Contains main view composition logic

### MediaThumbnailView

- **Purpose**: Displays thumbnail for photos/videos
- **Features**:
  - Lazy loads images from file system
  - Generates video thumbnails using AVFoundation
  - Shows play icon overlay for videos
  - Loading state with ProgressView

### YearSection

- **Purpose**: Groups and displays media by year
- **Features**:
  - Shows year header with item count
  - LazyVGrid layout (3 columns)
  - Switches between selectable/normal modes
  - Sorts items by date (newest first)

### FolderCard

- **Purpose**: Displays album/folder in horizontal scroll
- **Features**:
  - Folder icon with accent color
  - Folder name and item count
  - Tap to navigate to folder view

### MediaDetailView

- **Purpose**: Full-screen media viewer
- **Features**:
  - Pinch-to-zoom gesture
  - Delete functionality
  - Black background for focus

### SelectableThumbnailView

- **Purpose**: Thumbnail with selection checkbox
- **Features**:
  - Visual selection state (checkmark)
  - Toggle selection on tap

### TappableThumbnailView

- **Purpose**: Navigation wrapper for thumbnails
- **Features**:
  - NavigationLink to detail view
  - Plain button style

### MoveToFolderSheet

- **Purpose**: Modal for organizing items
- **Features**:
  - List of all folders
  - "Remove from Album" option (when in folder view)
  - Add to selected folder

## 🎯 Key Features

1. **Multi-Folder Support**: Items can belong to multiple albums simultaneously
2. **Year-Based Organization**: Automatic grouping by import year
3. **Batch Operations**: Select multiple items for deletion or folder assignment
4. **File Import**: Support for images and videos via system file picker
5. **Persistent Storage**: All data saved locally using JSON + file system
6. **Selection Mode**: Toggle between viewing and selection modes
7. **Responsive UI**: Adapts to main view vs. folder view states

## 🔐 Data Persistence

### Storage Location

- **Files**: `Documents/Media/` directory
- **Metadata**:
  - `Documents/Media/mediaItems.json`
  - `Documents/Media/folders.json`

### Persistence Strategy

- **Synchronous writes** on every mutation
- **Lazy loading** of image data (only when displayed)
- **File validation** on load (removes items with missing files)

## 🚀 Future Enhancements

Potential areas for expansion:

- Video playback in MediaDetailView
- Search functionality
- Date-based filtering (not just year)
- Export/share functionality
- Cloud sync integration
- Photo editing capabilities

## 📝 Development Notes

- Uses SwiftUI's modern declarative syntax
- Leverages `@Published` and `ObservableObject` for reactive updates
- File system access uses security-scoped resources for imported files
- Video thumbnail generation uses AVFoundation asynchronously
- Design system centralized in `AppTheme.swift` for consistency
