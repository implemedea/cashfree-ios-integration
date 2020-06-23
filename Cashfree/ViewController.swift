//
//  ViewController.swift
//  Cashfree
//
//  Created by Sebastin on 08/06/20.
//  Copyright © 2020 Sebastin. All rights reserved.
//

/**
 documents link - https://docs.cashfree.com/pg/ios
 */

/**
 test data - https://docs.cashfree.com/docs/resources/#test-data
 */


import UIKit
import CFSDK
import Alamofire

enum PaymentType: Int {
    case webViewCheckout = 1
    case seemless = 2
}
class ViewController: UIViewController, UITableViewDelegate {
    
    var paymentType: PaymentType = .webViewCheckout {
        didSet {
          if paymentType == .webViewCheckout {
               stackviewSeemless.isHidden = true
           } else {
               stackviewSeemless.isHidden = false
           }
        }
    }
    
    @IBOutlet weak var stackviewSeemless: UIStackView!
    
    // environment can be either be TEST or PROD
    let environment: String = "TEST"
    
    //To get the appId login to Cashfree Merchant Dashboard.
    let appId: String = "18061c5e143316df845d40d3416081"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackviewSeemless.isHidden = true
    }
    
    @IBAction func webviewCheckout(_ sender: Any) {
        paymentType = .webViewCheckout
        paymentRedirection(param: getPaymentParams())
    }
    
    @IBAction func seamless(_ sender: Any) {
        paymentType = .seemless
    }
    
    /**
     https://docs.cashfree.com/pg/ios/running
     */
    
    @IBAction func cardPayment(_ sender: Any) {
        var cardPayment: Dictionary<String, String> = getPaymentParams()
        let cardParams = [
            "paymentOption": "card",
            "card_number": "4444333322221111",
            "card_holder": "Test",
            "card_expiryMonth": "07",
            "card_expiryYear": "2023",
            "card_cvv": "123"
        ]
        cardPayment.merge(cardParams){(current, _) in current}
        print(cardPayment)
        paymentRedirection(param: cardPayment)
    }
    
    @IBAction func upiPayment(_ sender: Any) {
        var cardPayment: Dictionary<String, String> = getPaymentParams()
              let cardParams = [
                   "paymentOption": "upi",
                     "upi_vpa": "testsuccess@gocash",
                     "upiMode": ""
              ]
              cardPayment.merge(cardParams){(current, _) in current}
              print(cardPayment)
              paymentRedirection(param: cardPayment)
    }
    
    @IBAction func netBanking(_ sender: Any) {
        var cardPayment: Dictionary<String, String> = getPaymentParams()
              let netBankingParams = [
                  "paymentOption": "nb",
                  "paymentCode": "3333"
              ]
              cardPayment.merge(netBankingParams){(current, _) in current}
              print(cardPayment)
              paymentRedirection(param: cardPayment)
    }
    
    @IBAction func walletPayment(_ sender: Any) {
           var cardPayment: Dictionary<String, String> = getPaymentParams()
                 let walletParams = [
                     "paymentOption": "wallet",
                     "paymentCode": "4001"
                 ]
                 cardPayment.merge(walletParams){(current, _) in current}
                 print(cardPayment)
                 paymentRedirection(param: cardPayment)
       }
    
    func paymentRedirection(param: Dictionary<String, String>) {
        let cashfreeVC = CFViewController(params: param, appId: self.appId, env: self.environment, callBack: self)
        self.navigationController?.pushViewController(cashfreeVC, animated: true)
    }
    
    func getPaymentParams() -> Dictionary<String, String> {
        return [
            "orderId": "Order0011",
            "tokenData" : "F49JCN4MzUIJiOicGbhJCLiQ1VKJiOiAXe0Jye.Ds9JSNkZ2NyIjN3IjMmVWNiojI0xWYz9lIsgTOwAjM1UTO1EjOiAHelJCLiIlTJJiOik3YuVmcyV3QyVGZy9mIsEjOiQnb19WbBJXZkJ3biwiIxEDMwIXZkJ3TiojIklkclRmcvJye.GZ6AOuz86NcH13iOzto8aGxpYNK8g9hSA9LuAbPGoKecesvTyXKIC9Pgk4qqdofbpM",
            "orderAmount": "1",
            "customerName": "Arjun",
            "orderNote": "Order Note",
            "orderCurrency": "INR",
            "customerPhone": "9012341234",
            "customerEmail": "sample@gmail.com",
            "notifyUrl": "https://test.gocashfree.com/notify"
        ]
    }
    
    //MARK:- ToDo
    /// need to send orderId, orderAmount and orderCurrency to back end server, in back end server we need to write code to fetch cftoken and send back to front end
    /// - Parameters:
    ///   - orderId: random value
    ///   - orderAmount: order amount
    ///   - orderCurrency: order currency
    func getCFtoken(orderId: String, orderAmount: Double, orderCurrency: String){
        
    }
}

extension ViewController: ResultDelegate {
    func onPaymentCompletion(msg: String) {
        print("Result Delegate : onPaymentCompletion")
        print(msg)
        let data = msg.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,String>
            {
                if let orderId = jsonArray["orderId"], let referenceId = jsonArray["referenceId"], let orderAmount = jsonArray["orderAmount"], let txStatus = jsonArray["txStatus"], let txMsg = jsonArray["txMsg"], let txTime = jsonArray["txTime"], let paymentMode = jsonArray["paymentMode"], let signature = jsonArray["signature"] {
                     let response = "orderId: \(orderId)" + "\n" + "referenceId: \(referenceId)" + "\n" + "orderAmount: \(orderAmount)" + "\n" + "txStatus: \(txStatus)" + "txMsg: \(txMsg)" + "\n" + "txTime: \(txTime)" + "\n" + "paymentMode: \(paymentMode)" + "\n" + "signature: \(signature)";
                    
                    let alertController = UIAlertController(title: "Payment response", message: response, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                        print("You've pressed Ok");
                    }
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
    }
}


