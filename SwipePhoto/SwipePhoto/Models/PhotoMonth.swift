import Foundation
import Photos

struct PhotoMonth: Identifiable {
    let id = UUID()
    let month: Int
    let year: Int
    let assets: [PHAsset]
    
    var title: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM ''yy"
        if let firstAsset = assets.first {
            let date = firstAsset.creationDate ?? Date()
            return dateFormatter.string(from: date).uppercased()
        }
        return "\(month)/\(year)"
    }
} 