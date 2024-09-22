import ImageFeedApp
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeedApp.WebViewPresenterProtocol?

    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {

    }

    func setProgressHidden(_ isHidden: Bool) {

    }
}
