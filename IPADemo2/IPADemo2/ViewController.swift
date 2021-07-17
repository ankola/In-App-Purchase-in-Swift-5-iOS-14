//
//  ViewController.swift
//  IPADemo2
//
//  Created by Savan Ankola on 12/07/21.
//

import UIKit
import SwiftyStoreKit
import StoreKit

public var ProductId : String = "com.temporary.id2"//
public var SharedSecretID : String = "688151f81fcf443da4ebe8a24a1b3fc8"
public var viewUnlockPremioumContent : UIView = UIView()
public var lblExDate : UILabel = UILabel()
public var vc : UIViewController = UIViewController()

class ViewController: UIViewController {

    @IBOutlet weak var viewSubscriptionPurchased: UIView!
    @IBOutlet weak var lblDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewSubscriptionPurchased.tag == 1 {
            self.viewSubscriptionPurchased.isHidden = false
        }
        vc = self
        viewUnlockPremioumContent = self.viewSubscriptionPurchased
        lblExDate = self.lblDescription
    }

    //MARK:- ----- UIButton Action ----------
    @IBAction func btnBuY(_ sender: Any) {
        self.Purchase()
    }
    
    @IBAction func btnRestore(_ sender: Any) {
        self.ResoreProduct()
    }
    
    @IBAction func btnFetchProducts(_ sender: Any) {
        self.RetrieveProductsInfo()
    }
    
    @IBAction func btnVerifyReceipt(_ sender: Any) {
        self.verifyReceipt(isPopupDisplay: true, isFromRestore: false)
    }
    
    @IBAction func btnCancelSubscription(_ sender: Any) {
//        DispatchQueue.main.async {
//              UIApplication.shared.open(URL(string: "https://apps.apple.com/account/subscriptions")!, options: [:], completionHandler: nil)
//        }
    }

    func Purchase() {
        SwiftyStoreKit.purchaseProduct(ProductId, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                if purchase.needsFinishTransaction {
                    // Deliver content from server, then:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
//                self.alertWithTitle(title: "Thank You", message: "Purchase completed")
                self.verifyReceipt(isPopupDisplay: false, isFromRestore: false)
//                Downloading content hosted with Apple
//                let downloads = purchase.transaction.downloads
//                if !downloads.isEmpty {
//                    SwiftyStoreKit.start(downloads)
//                }

            case .error(let error):
                switch error.code {
                case .unknown:
                    print("Unknown error. Please contact support")
                    self.alertWithTitle(title: "Purchase Failed", message: "Unknown Error. Please Contact Support")
                    
                case .clientInvalid:
                    print("Not allowed to make the payment")
                    self.alertWithTitle(title: "Purchase Failed", message: "Not allowed to make the payment")

                case .paymentCancelled:
                    self.alertWithTitle(title: "Purchase Failed", message: "Payment Cancelled")
                    break
                    
                case .paymentInvalid:
                    print("The purchase identifier was invalid")
                    self.alertWithTitle(title: "Purchase Failed", message: "The purchase identifier was invalid")

                case .paymentNotAllowed:
                    print("The device is not allowed to make the payment")
                    self.alertWithTitle(title: "Purchase Failed", message: "The device is not allowed to make the payment")

                case .storeProductNotAvailable:
                    print("The product is not available in the current storefront")
                    self.alertWithTitle(title: "Purchase Failed", message: "The product is not available in the current storefront")

                case .cloudServicePermissionDenied:
                    print("Access to cloud service information is not allowed")
                    self.alertWithTitle(title: "Purchase Failed", message: "Access to cloud service information is not allowed")

                case .cloudServiceNetworkConnectionFailed:
                    print("Could not connect to the network")
                    self.alertWithTitle(title: "Purchase Failed", message: "Could not connect to the network")

                case .cloudServiceRevoked:
                    print("User has revoked permission to use this cloud service")
                    self.alertWithTitle(title: "Purchase Failed", message: "User has revoked permission to use this cloud service")

                default:
                    print((error as NSError).localizedDescription)
                    self.alertWithTitle(title: "Purchase Failed", message: (error as NSError).localizedDescription)
                }
            }
        }
    }
    
    func ResoreProduct() {
        vc.startLoading()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            vc.stopLoading()
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases.description)")
                self.alertWithTitle(title: "Restore Failed", message: results.restoreFailedPurchases.description)
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                var str = ""
                for product in results.restoredPurchases {
                    str += "\nProductId: \(product.productId) transactionState: \(product.transaction.transactionState)"
                    print(str)
                    if product.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }
                }
                self.verifyReceipt(isPopupDisplay: false, isFromRestore: true)
            }
            else {
                print("Nothing to Restore")
                self.alertWithTitle(title: "Alert", message: "Nothing to Restore.")
            }
        }
    }
    
    func updatedDownloads() {
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                // process all downloaded files, then finish the transaction
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
    
    func RetrieveProductsInfo() {
        vc.startLoading()
        SwiftyStoreKit.retrieveProductsInfo([ProductId]) { result in
            vc.stopLoading()
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product Name: \(product.localizedTitle)\nProduct ID: \(product.productIdentifier)\nProduct Description: \(product.localizedDescription), price: \(priceString)")
                self.alertWithTitle(title: "Fetched Product", message: "Product Name: \(product.localizedTitle)\nProduct ID: \(product.productIdentifier)\nProduct Description: \(product.localizedDescription), \nprice: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
                self.alertWithTitle(title: "Alert", message: "Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(String(describing: result.error?.localizedDescription))")
                self.alertWithTitle(title: "Alert", message: "Error: \(String(describing: result.error?.localizedDescription))")
            }
        }
    }
    
    func fetchUpdatedReceipt() {
        vc.startLoading()
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            vc.stopLoading()
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                print("Fetch receipt success:\n\(encryptedReceipt)")
            case .error(let error):
                print("Fetch receipt failed: \(error)")
            }
        }
    }
    
    func verifyReceipt(isPopupDisplay : Bool, isFromRestore : Bool) {
        if isPopupDisplay {
            vc.startLoading()
        }
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: SharedSecretID)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: true) { result in
            switch result {
            case .success(let receipt):
                print("Verify receipt success: \(receipt)")
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: ProductId,
                    inReceipt: receipt)
                vc.stopLoading()

                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("Product Id \(ProductId) is valid until \(expiryDate)\n")//items : \(items)\n
                    viewUnlockPremioumContent.isHidden = false
                    viewUnlockPremioumContent.tag = 1
                    lblExDate.text = "Product Id \(ProductId) is valid until \(expiryDate).\nPurchase Date:\(String(describing: items.first?.purchaseDate))"
                    if isPopupDisplay {
                        self.alertWithTitle(title: "Receipt verification", message: "\(ProductId) is valid until \(expiryDate)\nitems : \(items)\n")
                    } else if isFromRestore {
                        self.alertWithTitle(title: "Restore Success.", message: "\(ProductId) is valid until \(expiryDate).")
                    }

                case .expired(let expiryDate, let items):
                    print("\(ProductId) is expired since \(expiryDate)\n")
                    viewUnlockPremioumContent.isHidden = true
                    viewUnlockPremioumContent.tag = 0
                    if isPopupDisplay {
                        self.alertWithTitle(title: "Receipt verification", message: "\(ProductId) is expired since \(expiryDate)\nitems : \(items)\n")
                    } else if isFromRestore {
                        self.alertWithTitle(title: "Alert For Restore", message: "\(ProductId) is expired since \(expiryDate)\nitems : \(items)\n")
                    }

                case .notPurchased:
                    print("The user has never purchased \(ProductId)")
                    viewUnlockPremioumContent.isHidden = true
                    viewUnlockPremioumContent.tag = 0
                    if isPopupDisplay {
                        self.alertWithTitle(title: "Receipt verification", message: "The user has never purchased \(ProductId)")
                    } else if isFromRestore {
                        self.alertWithTitle(title: "Alert For Restore", message: "The user has never purchased \(ProductId)")
                    }
                }
                
            case .error(let error):
                vc.stopLoading()
                print("Verify receipt failed: \(error.localizedDescription)")
                switch error {
                case .noReceiptData:
                    self.alertWithTitle(title: "Receipt verification", message: "No receipt data. Try again.")
                case .networkError(let error):
                    self.alertWithTitle(title: "Receipt verification", message: "Network error while verifying receipt: \(error)")
                default:
                    self.alertWithTitle(title: "Receipt verification", message: "Receipt verification failed: \(error)")
                }
            }
        }
    }
}



