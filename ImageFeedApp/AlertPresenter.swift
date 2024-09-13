import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func present(_ alertToPresent: UIAlertController)
}

enum AlertType {
    case authErrorAlert
    case likeErrorAlert
    case singleImageErrorAlert
}

final class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
    
    func showAlert(alertType: AlertType, action: (() -> ())?=nil) {
        switch alertType {
        case .authErrorAlert:
            delegate?.present(createAuthErrorAlert())
        case .likeErrorAlert:
            delegate?.present(createLikeErrorAlert())
        case .singleImageErrorAlert:
            delegate?.present(createSingleImageErrorAlert(action: action))
        }
        
        
    }
    
    private func createAuthErrorAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "networkAuthErrorAlert"
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        return alert
    }
    
    private func createLikeErrorAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось изменить лайк на фото",
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "networkLikeErrorAlert"
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        return alert
    }
    
    private func createSingleImageErrorAlert(action: (() -> ())?) -> UIAlertController {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Попробовать еще раз?",
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
}
