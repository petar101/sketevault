import SwiftUI

struct AppLogo: View {
    var size: CGFloat = 32
    
    var body: some View {
        Image(systemName: "photo.stack")
            .font(.system(size: size, weight: .medium))
            .foregroundColor(.accentColor)
    }
}

