import UIKit

import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    let contentImage = UIImageView()
    let likeButton = UIButton()
    let dateStamp = UILabel()
    
    weak var delegate: ImagesListCellDelegate?
    
    private let gradientView: UIView = UIView()
    
    static let reuseIdentifier = "ImagesListCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .ypBlack
        createImageView()
        createDateStamp()
        createLikeButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createImageView() {
        contentImage.translatesAutoresizingMaskIntoConstraints = false
        contentImage.backgroundColor = .ypGray
        contentView.addSubview(contentImage)
        contentImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        contentImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        contentImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        contentImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
        contentImage.layer.cornerRadius = 16
        contentImage.clipsToBounds = true
    }
    
    private func createDateStamp() {
        dateStamp.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateStamp)
        dateStamp.leadingAnchor.constraint(equalTo: contentImage.leadingAnchor, constant: 8).isActive = true
        dateStamp.bottomAnchor.constraint(equalTo: contentImage.bottomAnchor, constant: -8).isActive = true
        dateStamp.font = UIFont(name: "SFPro-Regular", size: 13)
        dateStamp.textColor = UIColor.ypWhite
    }
    
    private func createLikeButton() {
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        contentView.addSubview(likeButton)
        likeButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        likeButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        likeButton.trailingAnchor.constraint(equalTo: contentImage.trailingAnchor).isActive = true
        likeButton.topAnchor.constraint(equalTo: contentImage.topAnchor).isActive = true
    }
    
    @objc
    private func didTapLikeButton() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func addGradientIfNeeded() {
        guard gradientView.superview == nil else { return }
        let gradientHeight = 30.0
        
        contentImage.addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.leadingAnchor.constraint(equalTo: contentImage.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: contentImage.trailingAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: contentImage.bottomAnchor).isActive = true
        gradientView.heightAnchor.constraint(equalToConstant: gradientHeight).isActive = true
        contentImage.clipsToBounds = true
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: gradientHeight)
        gradient.colors = [UIColor.clear.cgColor, UIColor.ypBlack.withAlphaComponent(0.2).cgColor]
        gradientView.layer.addSublayer(gradient)
    }
    
    func setLikeImage(isLiked: Bool) {
        switch isLiked {
        case true:
            likeButton.setImage(.likeOn, for: .normal)
        case false:
            likeButton.setImage(.likeOff, for: .normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentImage.kf.cancelDownloadTask()
    }
}
