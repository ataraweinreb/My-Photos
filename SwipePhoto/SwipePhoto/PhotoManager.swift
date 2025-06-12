import Foundation
import Photos

class PhotoManager: ObservableObject {
    @Published var photoMonths: [PhotoMonth] = []
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    init() {
        checkPermission()
    }
    
    func checkPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.authorizationStatus = status
                if status == .authorized || status == .limited {
                    self.fetchPhotos()
                }
            }
        }
    }
    
    func fetchPhotos() {
        var grouped: [String: [PHAsset]] = [:]
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        assets.enumerateObjects { asset, _, _ in
            guard let date = asset.creationDate else { return }
            let comps = Calendar.current.dateComponents([.year, .month], from: date)
            let key = "\(comps.year!)-\(comps.month!)"
            grouped[key, default: []].append(asset)
        }
        
        let months = grouped.map { (key, assets) -> PhotoMonth in
            let comps = key.split(separator: "-")
            return PhotoMonth(month: Int(comps[1])!, year: Int(comps[0])!, assets: assets)
        }
        .sorted { ($0.year, $0.month) > ($1.year, $1.month) }
        
        DispatchQueue.main.async {
            self.photoMonths = months
        }
    }
} 