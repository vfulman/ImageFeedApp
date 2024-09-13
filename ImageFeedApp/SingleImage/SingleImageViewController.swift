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
    
    let singleImage = UIImageView()
    private let backwardButton = UIButton()
    private let scrollView = UIScrollView()
    private let shareButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.05
        scrollView.maximumZoomScale = 1.25
        createScrollView()
        createSingleImage()
        createBackwardButton()
        createShareButton()

        scrollView.delegate = self
        
//        guard let image else { return }
//        singleImage.image = image
//        singleImage.frame.size = image.size
//        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func createScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.backgroundColor = .ypBlack
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    private func createSingleImage() {
        singleImage.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(singleImage)
        singleImage.contentMode = .scaleAspectFit
    }
    
    private func createBackwardButton() {
        backwardButton.setImage(UIImage(resource: .backward), for: .normal)
        backwardButton.translatesAutoresizingMaskIntoConstraints = false
        backwardButton.addTarget(self, action: #selector(didTapBackwardButton), for: .touchUpInside)
        view.addSubview(backwardButton)
        backwardButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        backwardButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        backwardButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: -1).isActive = true
        backwardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
    }
    
    private func createShareButton() {
        shareButton.setImage(UIImage(resource: .share), for: .normal)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        view.addSubview(shareButton)
        shareButton.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        shareButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
    }
    
    @objc
    private func didTapBackwardButton() {
        dismiss(animated: true)
    }
    
    @objc
    private func didTapShareButton() {
        guard let image else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        guard image.size.width != 0, image.size.height != 0 else { return }

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
