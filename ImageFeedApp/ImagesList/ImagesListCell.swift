//
//  ImagesListCell.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 23.08.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet var contentImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateStamp: UILabel!
    
    private let gradientView: UIView = UIView()
    
    static let reuseIdentifier = "ImagesListCell"
    
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
}
