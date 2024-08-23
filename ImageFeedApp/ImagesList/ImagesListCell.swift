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
    
    static let reuseIdentifier = "ImagesListCell"

}
