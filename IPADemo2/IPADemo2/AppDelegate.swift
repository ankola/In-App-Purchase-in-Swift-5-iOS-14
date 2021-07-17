//
//  AppDelegate.swift
//  IPADemo2
//
//  Created by Savan Ankola on 12/07/21.
//

import UIKit
import SwiftyStoreKit
import StoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
                
        NotificationCenter.default.addObserver(forName:UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { (_) in
            vc.startLoading()
            self.VerifySubscription()
        }
        self.setupIAP()
        return true
    }
    
    func setupIAP() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in

            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("Transactions productId \(purchase.transaction.transactionState.debugDescription): \(purchase.productId)   Transaction Identifier \(purchase.transaction.transactionIdentifier ?? "")    Transaction State \(purchase.transaction.transactionState)")
                    print("Unlock content ", Date())
//                    self.VerifySubscription()
                    
                case .failed, .purchasing, .deferred:
                    print("Not purchased")
                    break // do nothing
                default:
                    print("Not purchased")
                    break // do nothing
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
    
    func VerifySubscription() {
      print("---- Verifying Subscription......")
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: SharedSecretID)
        
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: true) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: ProductId,
                    inReceipt: receipt)
//                    print("receipt - ", receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("---- \(ProductId) is valid until \(expiryDate)\n")//\nitems : \(items)
                    viewUnlockPremioumContent.isHidden = false
                    viewUnlockPremioumContent.tag = 1
                    lblExDate.text = "Product Id \(ProductId) is valid until \(expiryDate).\nPurchase Date:\(String(describing: items.first?.purchaseDate))"
                case .expired(let expiryDate, _):
                    print("---- \(ProductId) is expired since \(expiryDate)\n")
                    viewUnlockPremioumContent.isHidden = true
                    viewUnlockPremioumContent.tag = 0

                case .notPurchased:
                    print("---- \(ProductId) The user has never purchased \(ProductId)")
                    viewUnlockPremioumContent.isHidden = true
                    viewUnlockPremioumContent.tag = 0
                }
                vc.stopLoading()

//                if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
//                    FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
//
//                    do {
//                        let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
//                        print("receiptData - ", receiptData)
//
//                        let receiptString = receiptData.base64EncodedString(options: [])
//                        print("receiptString - ", receiptString)
//                        // Read receiptData
//                    }
//                    catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
//                }
                
            case .error(let error):
                print("---- \(ProductId) Receipt verification failed: \(error.localizedDescription)")
                viewUnlockPremioumContent.isHidden = true
                viewUnlockPremioumContent.tag = 0
                vc.stopLoading()
            }
        }
    }
    
  

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

