//
//  SingleImageViewController.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 27.08.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    @IBOutlet private var singleImage: UIImageView!
    @IBOutlet var backwardButton: UIButton!
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            singleImage.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        singleImage.image = image
    }
    
    @IBAction func didTapBackwardButton() {
        dismiss(animated: true, completion: nil)
    }
    
}
