import ImageFeedApp
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var photos: [ImageFeedApp.Photo] = []
    
    func changeLike(photoIndex: Int, _ completion: @escaping (Result<Void, ImageFeedApp.NetworkError>) -> Void) {
        let photo = photos[photoIndex]
        let newPhoto = Photo(
            id: photo.id,
            size: photo.size,
            createdAt: photo.createdAt,
            welcomeDescription: photo.welcomeDescription,
            thumbImageURL: photo.thumbImageURL,
            largeImageURL: photo.largeImageURL,
            isLiked: !photo.isLiked
        )
        photos[photoIndex] = newPhoto
    }
    
    func fethPhotosNextPage() {
        photos = [
            Photo(
                id: "test_id",
                size: .zero,
                createdAt: Date(),
                welcomeDescription: nil,
                thumbImageURL: "test_thumb_url",
                largeImageURL: "test_large_url",
                isLiked: false
            )
        ]
    }
    
    func viewDidLoad() {
        fethPhotosNextPage()
    }
}
