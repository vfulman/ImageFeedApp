//
//  SingleImageViewController.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 27.08.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard let image = image, isViewLoaded else { return }
            singleImage.image = image
            singleImage.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet private var singleImage: UIImageView!
    @IBOutlet private var backwardButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        guard let image else { return }
        singleImage.image = image
        singleImage.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    @IBAction func didTapBackwardButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        singleImage
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let newContentSize = scrollView.contentSize
        let visibleRectSize = scrollView.bounds.size
        let dx = (visibleRectSize.width - newContentSize.width) / 2
        let dy = (visibleRectSize.height - newContentSize.height) / 2
        if dx > 0, dy > 0 {
            scrollView.contentInset = UIEdgeInsets(top: dy, left: dx, bottom: dy, right: dx)
        }
    }
}
