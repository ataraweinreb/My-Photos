# SwipePhotoDelete

A fun, colorful, and fast iOS app to help you clean your photos by swiping through them Tinder-style. Organizes your photos by month and lets you quickly keep or delete photos with a swipe.

## Features
- Organize photos by month
- Swipe left to delete, right to keep
- Colorful, easy-to-use interface
- Fast performance (thumbnails, preloading)

## Setup
1. Open the project in Xcode.
2. Make sure to run on a real device (not the simulator) for photo access.
3. The app will request permission to access your photo library on first launch.

## Permissions
- The app requires access to your photo library. Make sure `NSPhotoLibraryUsageDescription` is set in `Info.plist`.

## Structure
- `SwipePhotoDeleteApp.swift`: App entry point
- `HomeView.swift`: Main home screen
- `PhotoSwipeView.swift`: Swipe interface for photos
- `PhotoManager.swift`: Handles photo fetching and grouping
- `Models/PhotoMonth.swift`: Model for grouping photos by month
- `Utilities/Color+Extensions.swift`: Colorful gradients

## License
MIT 