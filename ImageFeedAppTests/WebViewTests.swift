@testable import ImageFeedApp
import XCTest

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }
    
    func testPresenterCallsLoadRequest() {
        //given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        let url = authHelper.authURL()
        // ???
        XCTAssertNotNil(url)
        guard let url else { return }
        let urlString = url.absoluteString
        
        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)

        guard var urlComponents = URLComponents(string: configuration.authURLString + "/native") else { return }
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test_code")]
        guard let url = urlComponents.url else { return }
        
        //when
        let code = authHelper.code(from: url)
        
        //then
        XCTAssertEqual(code, "test_code")
    }
    
    func testfetchPhotos() {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        
        presenter.viewDidLoad()
        XCTAssertFalse(viewController.photos.isEmpty)
    }
    
    func testChangeLikePhoto() {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        
        let photoIndex = 0
        presenter.viewDidLoad()
        let isLiked = viewController.photos[photoIndex].isLiked
        presenter.changeLike(photoIndex: photoIndex) { _ in }
        
        XCTAssertNotEqual(isLiked, viewController.photos[photoIndex].isLiked)
    }
    
    func testProfileLogout() {
        let presenter = ProfilePresenterSpy()
        XCTAssertNotNil(presenter.profile)
        presenter.logout()
        XCTAssertNil(presenter.profile)
    }
}
