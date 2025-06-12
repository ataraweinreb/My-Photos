import SwiftUI

struct HomeView: View {
    @ObservedObject var photoManager: PhotoManager
    @State private var selectedMonth: PhotoMonth?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    Text("swipewipe")
                        .font(.system(size: 40, weight: .bold))
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemPink).opacity(0.2))
                    
                    Button(action: {}) {
                        Text("on this day")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .background(Color.funGradients[0])
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Recents")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "tray.full")
                                .foregroundColor(.white)
                            Text("\(photoManager.photoMonths.first?.assets.count ?? 0)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, minHeight: 70)
                        .background(Color.funGradients[1])
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Random")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "shuffle")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, minHeight: 70)
                        .background(Color.funGradients[2])
                    }
                    
                    ForEach(Array(photoManager.photoMonths.enumerated()), id: \ .element.id) { idx, month in
                        Button(action: {
                            if !month.assets.isEmpty {
                                selectedMonth = month
                            }
                        }) {
                            Text(month.title)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(month.assets.isEmpty ? .gray : .black)
                                .frame(maxWidth: .infinity, minHeight: 70)
                                .background(Color.funGradients[(idx+3) % Color.funGradients.count])
                                .opacity(month.assets.isEmpty ? 0.5 : 1.0)
                        }
                        .disabled(month.assets.isEmpty)
                    }
                }
            }
            .sheet(item: $selectedMonth) { month in
                PhotoSwipeView(month: month, onBatchDelete: {
                    photoManager.fetchPhotos()
                })
            }
        }
    }
}
