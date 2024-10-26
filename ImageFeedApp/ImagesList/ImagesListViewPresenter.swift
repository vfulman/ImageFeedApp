import UIKit


public protocol ImagesListPresenterProtocol {
    var photos: [Photo] { get }
    func changeLike(photoIndex: Int, _ completion: @escaping (Result<Void, NetworkError>) -> Void)
    func fethPhotosNextPage()
    func viewDidLoad()
}


final class ImagesListPresenter: ImagesListPresenterProtocol {
    let imagesListService = ImagesListService.shared
    var photos: [Photo] {
        return imagesListService.photos
    }
    
    func viewDidLoad() {
        fethPhotosNextPage()
    }
    
    func fethPhotosNextPage() {
        imagesListService.fetchPhotosNextPage { _ in }
    }
    
    func changeLike(photoIndex: Int, _ completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let photo = photos[photoIndex]
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .failure(let error):
                print("\(#file):\(#function):Change like for image failure \(error.description))")
                completion(.failure(error))
            case .success():
                completion(.success(()))
            }
        }
    }

    
}
