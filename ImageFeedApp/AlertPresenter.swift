import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func present(_ alertToPresent: UIAlertController)
}

final class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
    
    func showAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "networkAuthErrorAlert"
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        delegate?.present(alert)
    }
}
