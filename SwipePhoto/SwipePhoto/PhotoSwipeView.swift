import SwiftUI
import PhotosUI

struct PhotoSwipeView: View {
    let month: PhotoMonth
    var onBatchDelete: (() -> Void)? = nil
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var keepCount = 0
    @State private var deleteCount = 0
    @State private var isAnimatingOff = false
    @GestureState private var dragState = CGSize.zero
    @State private var assetsToDelete: [PHAsset] = []
    @State private var isDeleting = false
    @State private var showDeleted = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                HStack {
                    Button(action: {
                        handleSessionEnd()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    Text(month.title)
                        .font(.title)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(min(currentIndex+1, month.assets.count))/\(month.assets.count)")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .padding()
                
                Spacer()
                
                if isDeleting {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                        Text("Deleting \(assetsToDelete.count) photos...")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                } else if showDeleted {
                    Text("Deleted \(deleteCount) photos!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                presentationMode.wrappedValue.dismiss()
                                onBatchDelete?()
                            }
                        }
                } else if month.assets.isEmpty {
                    Text("No photos in this month!")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                } else {
                    ZStack {
                        ForEach((currentIndex..<min(currentIndex+2, month.assets.count)).reversed(), id: \.self) { idx in
                            PhotoCard(
                                asset: month.assets[idx],
                                offset: idx == currentIndex ? offset : .zero,
                                overlayText: idx == currentIndex ? overlayText : nil
                            )
                            .offset(x: idx == currentIndex ? offset.width : 0, y: CGFloat(idx - currentIndex) * 10)
                            .rotationEffect(.degrees(idx == currentIndex ? Double(offset.width / 12) : 0))
                            .scaleEffect(idx == currentIndex ? 1.0 : 0.96)
                            .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.7, blendDuration: 0.5), value: offset)
                            .allowsHitTesting(idx == currentIndex)
                            .gesture(
                                idx == currentIndex ?
                                DragGesture()
                                    .updating($dragState) { value, state, _ in
                                        state = value.translation
                                    }
                                    .onChanged { gesture in
                                        offset = gesture.translation
                                    }
                                    .onEnded { gesture in
                                        let velocity = gesture.predictedEndTranslation.width - gesture.translation.width
                                        let threshold: CGFloat = 100
                                        let shouldKeep = offset.width > threshold || velocity > 200
                                        let shouldDelete = offset.width < -threshold || velocity < -200
                                        if shouldKeep {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                offset = CGSize(width: 1000, height: 0)
                                            }
                                            isAnimatingOff = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                                keepCount += 1
                                                nextPhoto()
                                                offset = .zero
                                                isAnimatingOff = false
                                            }
                                        } else if shouldDelete {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                offset = CGSize(width: -1000, height: 0)
                                            }
                                            isAnimatingOff = true
                                            if currentIndex < month.assets.count {
                                                let assetToDelete = month.assets[currentIndex]
                                                assetsToDelete.append(assetToDelete)
                                                deleteCount += 1
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                                nextPhoto()
                                                offset = .zero
                                                isAnimatingOff = false
                                            }
                                        } else {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                offset = .zero
                                            }
                                        }
                                    }
                                : nil
                            )
                        }
                    }
                    .frame(height: 500)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                
                if currentIndex >= month.assets.count && !month.assets.isEmpty && !isDeleting && !showDeleted {
                    Button(action: {
                        handleSessionEnd()
                    }) {
                        Text("All done! Tap to delete \(assetsToDelete.count) photos")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.top, 40)
                    }
                }
                
                Spacer()
                
                HStack {
                    VStack {
                        Text("DELETE")
                            .font(.title2)
                            .foregroundColor(.purple)
                        Text("\(deleteCount)")
                            .font(.title)
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.green.opacity(0.5))
                            .cornerRadius(8)
                    }
                    Spacer()
                    VStack {
                        Text("KEEP")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("\(keepCount)")
                            .font(.title)
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.green.opacity(0.5))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
        .onDisappear {
            handleSessionEnd()
        }
    }
    
    var overlayText: String? {
        if offset.width > 60 {
            return "KEEP"
        } else if offset.width < -60 {
            return "DELETE"
        } else {
            return nil
        }
    }
    
    func nextPhoto() {
        if currentIndex < month.assets.count - 1 {
            currentIndex += 1
        } else {
            currentIndex += 1 // To show "All done!"
        }
    }
    
    func handleSessionEnd() {
        guard !assetsToDelete.isEmpty, !isDeleting, !showDeleted else { return }
        isDeleting = true
        deleteBatch(assets: assetsToDelete) {
            isDeleting = false
            showDeleted = true
            assetsToDelete.removeAll()
            // Notify parent to refresh
            onBatchDelete?()
        }
    }
    
    func deleteBatch(assets: [PHAsset], completion: @escaping () -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                completion()
            }
        })
    }
}

struct PhotoCard: View {
    let asset: PHAsset
    var offset: CGSize = .zero
    var overlayText: String? = nil
    @State private var image: UIImage? = nil
    
    var body: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                    .shadow(radius: 10)
            } else {
                Color.gray
                    .cornerRadius(20)
            }
            if let overlayText = overlayText {
                Text(overlayText)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(overlayText == "KEEP" ? .green : .purple)
                    .padding(16)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(16)
                    .padding(32)
                    .opacity(Double(min(abs(offset.width) / 120, 1)))
                    .animation(.easeInOut, value: offset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 500)
        .onAppear {
            fetchImage()
        }
    }
    
    func fetchImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isSynchronous = false
        manager.requestImage(for: asset, targetSize: CGSize(width: 800, height: 800), contentMode: .aspectFit, options: options) { img, _ in
            self.image = img
        }
    }
} 
