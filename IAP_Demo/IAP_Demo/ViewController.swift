//
//  ViewController.swift
//  IAP_Demo
//
//  Created by Savan Ankola on 09/07/21.
//

import UIKit
import StoreKit

class ViewController: UIViewController {

    @IBOutlet weak var btnPlan1: UIButton!
    @IBOutlet weak var btnPlan2: UIButton!
    
    var Products = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnFetchPlan(_ sender: Any) {
        PKIAPHandler.shared.setProductIds(ids: ["com.temporary.id2"])
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
            guard self != nil else {return}
            self?.Products = products
            print("products - ", products.count)
            for p in products {
              print("Found product: \(p.productIdentifier), Product Title: \(p.localizedTitle), Product Price: \(p.price.floatValue)")
            }
            DispatchQueue.main.async {
                self?.btnPlan2.isHidden = false
//                self?.btnPlan2.isHidden = false
            }
        }
    }
    
    @IBAction func btnRestorePlan(_ sender: Any) {
        PKIAPHandler.shared.restorePurchase()
    }
    
    @IBAction func btnPurchasePlan(_ sender: Any) {
        PKIAPHandler.shared.purchase(product: self.Products.first!) { (handelerType, product, paymenttransation) in
//            print("product bought: \(product!.productIdentifier), Product Title: \(product!.localizedTitle), Product Price: \(product!.price.floatValue)")
            
//            if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
//                FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
//
//                do {
//                    let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
//                    print(receiptData)
//
//                    let receiptString = receiptData.base64EncodedString(options: [])
//                    print(receiptString)
//                    // Read receiptData
//                }
//                catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
//            }
        }
    }
    
    
}

