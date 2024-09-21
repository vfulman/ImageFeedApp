import UIKit


final class SingleImageViewController: UIViewController {
    private let singleImage = UIImageView()
    private let backwardButton = UIButton()
    private let scrollView = UIScrollView()
    private let shareButton = UIButton()
    private let stubImage = UIImageView()
    
    private let alertPresenter = AlertPresenter()
    
    private var retryURL: String?
    
    func loadImage(url: String) {
        retryURL = url
        guard let url = URL(string: url) else { return }
        UIBlockingProgressHUD.show()
        stubImage.isHidden = false
        singleImage.kf.setImage(with: url) { [weak self] result in
            guard let self = self else { return }
            self.stubImage.isHidden = true
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure(let error):
                print("\(#file):\(#function): Image loading error \(error)")
                alertPresenter.showAlert(alertType: .singleImageErrorAlert) { [weak self] in
                    guard let self else { return }
                    guard let retryURL = self.retryURL else { return }
                    self.loadImage(url: retryURL)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.05
        scrollView.maximumZoomScale = 1.25
        createScrollView()
        createSingleImage()
        createStubView()
        createBackwardButton()
        createShareButton()
        
        alertPresenter.delegate = self
        scrollView.delegate = self
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
    
    private func createStubView() {
        stubImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubImage)
        stubImage.image = UIImage(resource: .stub)
        stubImage.widthAnchor.constraint(equalToConstant: 83).isActive = true
        stubImage.heightAnchor.constraint(equalToConstant: 75).isActive = true
        stubImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stubImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
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
        guard let image = singleImage.image else { return }
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

extension SingleImageViewController: AlertPresenterDelegate {
    func present(_ alertToPresent: UIAlertController) {
        present(alertToPresent, animated: true)
    }
}
