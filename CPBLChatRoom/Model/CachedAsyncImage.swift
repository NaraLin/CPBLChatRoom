

import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    @StateObject private var loader: ImageLoader
    private let content: (AsyncImagePhase) -> Content
    
    init(url: URL, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self._loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.content = content
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                content(.success(Image(uiImage: image)))
            } else if loader.error != nil {
                content(.failure(loader.error!))
            } else {
                content(.empty)
            }
        }
        .onAppear(perform: {
            loader.load()
        })
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var error: Error?
    private let url: URL
    private let cache: ImageCache
    
    init(url: URL, cache: ImageCache = .shared) {
        self.url = url
        self.cache = cache
    }
    
    func load() {
        if let cachedImage = cache.image(for: url) {
            self.image = cachedImage
            return
        }
        
        //cache no image > fetch image
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error {
                    self.error = error
                } else if let data,
                          let uiImage = UIImage(data: data) {
                    self.image = uiImage
                    self.cache.setImage(uiImage, url: self.url)
                }
            }
        }.resume()
        
    }
}
