import Foundation


struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}


final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    var task: URLSessionTask?
    
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var currentLoadedPage: Int?
    
    private enum ImageListServiceConstants {
        static let unsplashPhotosURLString = "\(Constants.defaultBaseURL)/photos"
        static let requestPhotosPerPage = "10"
        static let photosOrderedBy = "latest"
    }
    
    private struct PhotoResultBody: Decodable {
        let id: String
        let width: Int
        let height: Int
        let createdAt: String
        let description: String?
        let urls: UrlsResultBody
        let likedByUser: Bool
        
        enum CodingKeys: String, CodingKey {
            case id
            case width
            case height
            case createdAt = "created_at"
            case description
            case urls
            case likedByUser = "liked_by_user"
        }
    }
    
    private struct UrlsResultBody: Decodable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
    
    private init() {}
    
    func clearPhotosInfo() {
        photos.removeAll()
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        assert(Thread.isMainThread)
        
        guard task == nil else {
            print("\(#file):\(#function):\(NetworkError.duplicateRequest.description)")
            completion(.failure(NetworkError.duplicateRequest))
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
//        ??
        guard currentLoadedPage == nil else { return }
        currentLoadedPage = nextPage
        
        guard let request = makeImagesListRequest(page: nextPage)
        else {
            print("\(#file):\(#function):\(NetworkError.invalidRequest.description)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) {[weak self] (result: Result<[PhotoResultBody], NetworkError>) in
            DispatchQueue.main.async {
                guard let self else { return }
                self.task = nil
                switch result {
                case .failure(let error):
                    print("\(#file):\(#function):Fetch photos from page \(nextPage) failure \(error.description))")
                    completion(.failure(error))
                case .success(let decodedPhotosData):
                    self.lastLoadedPage = self.currentLoadedPage
                    for photo in decodedPhotosData {
                        self.photos.append(
                            Photo(
                                id: photo.id,
                                size: CGSize(width: photo.width, height: photo.height),
                                createdAt: ISO8601DateFormatter().date(from: photo.createdAt),
                                welcomeDescription: photo.description,
                                thumbImageURL: photo.urls.thumb,
                                largeImageURL: photo.urls.full,
                                isLiked: photo.likedByUser))
                    }
                    completion(.success(()))
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["LastLoadedPage": self.lastLoadedPage as Any]
                    )
                }
                self.currentLoadedPage = nil
            }
        }
        task.resume()
    }
    
    private func makeImagesListRequest(page: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: ImageListServiceConstants.unsplashPhotosURLString) else {
            print("\(#file):\(#function): Unable to create URLComponents with url string: \(ImageListServiceConstants.unsplashPhotosURLString)")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: ImageListServiceConstants.requestPhotosPerPage),
            URLQueryItem(name: "order_by", value: ImageListServiceConstants.photosOrderedBy),
        ]
        
        guard let url = urlComponents.url else {
            print("\(#file):\(#function): Unable to create URLComponents")
            return nil
        }
        
//        ???
        guard let token = OAuth2TokenStorage().loadToken()
        else {
            print("\(#file):\(#function): authorization token was not found")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, NetworkError>) -> Void) {
        assert(Thread.isMainThread)
        
//        ??
        guard task == nil else {
            print("\(#file):\(#function):\(NetworkError.duplicateRequest.description)")
            completion(.failure(NetworkError.duplicateRequest))
            return
        }
        
        guard let request = makeChangingLikeRequest(photoId: photoId, isLike: isLike)
        else {
            print("\(#file):\(#function):\(NetworkError.invalidRequest.description)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
//        ??
        let task = URLSession.shared.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.task = nil
                switch result {
                case .failure(let error):
                    print("\(#file):\(#function):Change like for image id \(photoId) failure \(error.description))")
                    completion(.failure(error))
                case .success(_):
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                    }
                    completion(.success(()))
                }
            }
        }
        task.resume()
    }
    
    private func makeChangingLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let url = URL(string: "\(ImageListServiceConstants.unsplashPhotosURLString)/\(photoId)/like")
        else {
            print("\(#file):\(#function): Can not create URL from string: \"\(ImageListServiceConstants.unsplashPhotosURLString)/\(photoId)/like\"")
            return nil
        }
        // ???
        guard let token = OAuth2TokenStorage().loadToken()
        else {
            print("\(#file):\(#function): authorization token was not found")
            return nil
        }
        
        var request = URLRequest(url: url)
        switch isLike {
        case true:
            request.httpMethod = "POST"
        case false:
            request.httpMethod = "DELETE"
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
        
    }
}


