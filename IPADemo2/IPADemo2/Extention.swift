//
//  Extention.swift
//  IPADemo2
//
//  Created by Savan Ankola on 12/07/21.
//

import Foundation
import UIKit

extension UIViewController {

    static let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    func startLoading() {
        let activityIndicator = UIViewController.activityIndicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.style = .gray
        }
        DispatchQueue.main.async {
            self.view.addSubview(activityIndicator)
        }
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
    }

    func stopLoading() {
        let activityIndicator = UIViewController.activityIndicator
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
        self.view.isUserInteractionEnabled = true
    }
}

//Alert Controller
extension ViewController {
    func alertWithTitle(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func showAlert(alert : UIAlertController) {
        guard let _ = self.presentedViewController else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
}
