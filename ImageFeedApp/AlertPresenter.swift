import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func present(_ alertToPresent: UIAlertController)
}

enum AlertType {
    case authErrorAlert
    case likeErrorAlert
    case singleImageErrorAlert
    case logoutAlert
}

final class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
    
    private enum AlertPresenterConstants {
        static let networkErrorTitle = "Что-то пошло не так("
        static let authErrorMessage = "Не удалось войти в систему"
        static let likeErrorMessage = "Не удалось изменить лайк на фото"
        static let singleImageErrorMessage = "Попробовать еще раз?"
        static let logoutTitle = "Пока, пока!"
        static let logoutMessage = "Уверены что хотите выйти?"
    }
    
    func showAlert(alertType: AlertType, action: (() -> ())?=nil) {
        switch alertType {
        case .authErrorAlert:
            delegate?.present(createAuthErrorAlert())
        case .likeErrorAlert:
            delegate?.present(createLikeErrorAlert())
        case .singleImageErrorAlert:
            delegate?.present(createSingleImageErrorAlert(action: action))
        case .logoutAlert:
            delegate?.present(createLogoutAlert(action: action))
        }
    }
    
    private func createAuthErrorAlert() -> UIAlertController {
        let alert = UIAlertController(title: AlertPresenterConstants.networkErrorTitle,
                                      message: AlertPresenterConstants.authErrorMessage,
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "networkAuthErrorAlert"
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        return alert
    }
    
    private func createLikeErrorAlert() -> UIAlertController {
        let alert = UIAlertController(title: AlertPresenterConstants.networkErrorTitle,
                                      message: AlertPresenterConstants.likeErrorMessage,
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "networkLikeErrorAlert"
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        return alert
    }
    
    private func createSingleImageErrorAlert(action: (() -> ())?) -> UIAlertController {
        let alert = UIAlertController(title: AlertPresenterConstants.networkErrorTitle,
                                      message: AlertPresenterConstants.singleImageErrorMessage,
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "networkSingleImageErrorAlert"
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { _ in
            action?()
        }
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        return alert
    }
    
    private func createLogoutAlert(action: (() -> ())?) -> UIAlertController {
        let alert = UIAlertController(title: AlertPresenterConstants.logoutTitle,
                                      message: AlertPresenterConstants.logoutMessage,
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "LogoutAlert"
        let retryAction = UIAlertAction(title: "Да", style: .default) { _ in
            action?()
        }
        
        let cancelAction = UIAlertAction(title: "Нет", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        
        retryAction.accessibilityIdentifier = "LogoutAlertYes"
        cancelAction.accessibilityIdentifier = "LogoutAlertNo"
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        alert.preferredAction = cancelAction
        return alert
    }
}
