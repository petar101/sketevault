import SwiftUI

struct AppLogo: View {
    var size: CGFloat = 32
    @State private var hasCustomLogo = false
    
    var body: some View {
        Group {
            if hasCustomLogo {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            } else {
            // Fallback to SF Symbol if custom image not found
            Image(systemName: "photo.stack")
                .font(.system(size: size, weight: .medium))
                .foregroundColor(Color.primaryAccent)
            }
        }
        .onAppear {
            // Check if custom logo exists in asset catalog
            hasCustomLogo = UIImage(named: "AppLogo") != nil
        }
    }
}

