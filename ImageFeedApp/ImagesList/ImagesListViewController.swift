import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
}


final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var photos: [Photo] {
        presenter?.photos ?? []
    }
    
    private let currentDate = Date()
    private let singleImageView = SingleImageViewController()
    private let imagesTableView = UITableView(frame: .zero, style: UITableView.Style.plain)
    private var oldPhotosCount = 0
    
    private var imagesListServiceObserver: NSObjectProtocol?
    private let alertPresenter = AlertPresenter()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTableView()
        singleImageView.modalPresentationStyle = .fullScreen
        imagesTableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        imagesTableView.separatorStyle = .none
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
        updateTableViewAnimated()
        presenter?.viewDidLoad()
        alertPresenter.delegate = self
    }
    
    func updateTableViewAnimated() {
        let newCount = photos.count
        if oldPhotosCount != newCount {
            imagesTableView.performBatchUpdates {
                let indexPaths = (oldPhotosCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                imagesTableView.insertRows(at: indexPaths, with: .automatic)
                oldPhotosCount = photos.count
            } completion: { _ in }
        }
    }
    
    private func createTableView() {
        imagesTableView.translatesAutoresizingMaskIntoConstraints = false
        imagesTableView.backgroundColor = UIColor(resource: .ypBlack)
        view.addSubview(imagesTableView)
        imagesTableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        imagesTableView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        imagesTableView.delegate = self
        imagesTableView.dataSource = self
        imagesTableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard
            let url = URL(string: photos[indexPath.row].thumbImageURL)
        else { return }
        cell.contentImage.kf.indicatorType = .activity
        cell.contentImage.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .stub)
        ) { result in
            switch result {
            case .success(_):
                self.imagesTableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                print("\(#file):\(#function): Photo image loading error \(error)")
            }
        }
        
        cell.setLikeImage(isLiked: photos[indexPath.row].isLiked)

        if let date = photos[indexPath.row].createdAt {
            cell.dateStamp.text = dateFormatter.string(from: date)
        } else {
            cell.dateStamp.text = ""
        }
        cell.addGradientIfNeeded()
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        singleImageView.loadImage(url: photos[indexPath.row].largeImageURL)
        present(singleImageView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageSize = photos[indexPath.row].size
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageSize.width
        let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
        
        return ceil(cellHeight)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            presenter?.fethPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = imagesTableView.indexPath(for: cell) else { return }
        UIBlockingProgressHUD.show()
        presenter?.changeLike(photoIndex: indexPath.row) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                print("\(#file):\(#function):Change like for image failure \(error.description))")
                UIBlockingProgressHUD.dismiss()
                alertPresenter.showAlert(alertType: .likeErrorAlert)
            case .success():
                cell.setLikeImage(isLiked: photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}

extension ImagesListViewController: AlertPresenterDelegate {
    func present(_ alertToPresent: UIAlertController) {
        present(alertToPresent, animated: true)
    }
}
