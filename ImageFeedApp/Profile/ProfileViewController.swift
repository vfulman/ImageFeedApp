import UIKit
import WebKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let storage = OAuth2TokenStorage()
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let bioLabel = UILabel()
    private let logoutButton = UIButton(type: .custom)
        
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypBlack)
        createProfileImageView()
        createNameLabel()
        createLoginNameLabel()
        createBioLabel()
        createLogoutButton()
        updateProfileDetails(profile: profileService.profile)
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateProfileImage()
        }
        updateProfileImage()
        
    }
    
    private func updateProfileImage() {
        guard
            let profileImageURL = ProfileImageService.shared.profileImageURL,
            let url = URL(string: profileImageURL)
        else { return }
        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .defaultUserpic)
        ) { result in
                switch result {
                case .success(let value):
//                    print(value.image)
                    print(value.cacheType)
                case .failure(let error):
                    print("\(#file):\(#function): Image loading error \(error)")
                }
            }
    }
    
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profile
        else {
            print("\(#file):\(#function): Can not update profile info")
            return
        }
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        bioLabel.text = profile.bio
        
    }
    
    private func createProfileImageView() {
        let imageSize = 70.0
        let profileImage = UIImage(resource: .defaultUserpic)
        profileImageView.image = profileImage
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        profileImageView.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        profileImageView.layer.cornerRadius = imageSize / 2
        profileImageView.clipsToBounds = true

    }
    
    private func createNameLabel() {
        nameLabel.text = "Name"
        nameLabel.font = UIFont(name: "SFPro-Bold", size: 23)
        nameLabel.textColor = UIColor.ypWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
    }
    
    private func createLoginNameLabel() {
        loginNameLabel.text = "@login_name"
        loginNameLabel.font = UIFont(name: "SFPro-Regular", size: 13)
        loginNameLabel.textColor = UIColor.ypGray
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        loginNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func createBioLabel() {
        bioLabel.text = "Bio Info"
        bioLabel.font = UIFont(name: "SFPro-Regular", size: 13)
        bioLabel.textColor = UIColor.ypWhite
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bioLabel)
        bioLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        bioLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func createLogoutButton() {
        logoutButton.setImage(UIImage(resource: .logout), for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(logoutButton)
        logoutButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -14).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    }
    
    @objc
    private func didTapLogoutButton() {
        let isRemoved = storage.removeToken()
        guard isRemoved else {
            print("\(#file):\(#function): Cant remove token from storage")
            return
        }
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("\(#file):\(#function): Invalid window configuration")
            return
        }
        window.rootViewController = SplashViewController()
    }
}
