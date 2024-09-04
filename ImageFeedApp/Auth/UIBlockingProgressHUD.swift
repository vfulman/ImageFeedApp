//
//  UIBlockingProgressHUD.swift
//  ImageFeedApp
//
//  Created by Виталий Фульман on 04.09.2024.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.mediaSize = 25
        ProgressHUD.marginSize = 26
        ProgressHUD.animate(interaction: false)
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
