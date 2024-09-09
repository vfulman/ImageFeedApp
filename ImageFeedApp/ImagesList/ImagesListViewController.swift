import UIKit

final class ImagesListViewController: UIViewController {
    private let photosName = Array(0..<20).map{ "\($0)" }
    private let currentDate = Date()
    private let singleImageView = SingleImageViewController()
    private let imagesTableView = UITableView(frame: .zero, style: UITableView.Style.plain)
    
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
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        cell.contentImage.image = image
        cell.dateStamp.text = dateFormatter.string(from: currentDate)
        let likeImage = indexPath.row % 2 == 0 ? UIImage(named: "like_on") : UIImage(named: "like_off")
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.addGradientIfNeeded()
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        singleImageView.image = image
        present(singleImageView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / image.size.width
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return ceil(cellHeight)
    }
}
