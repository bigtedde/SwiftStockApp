//
//  ViewController.swift
//  StockApp
//
//  Created by Theodore Lawson on 9/1/22.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    var stockData = "DEFAULT STOCK DATA"
    var ticker = "SNAP"
    @IBOutlet var field: UITextField!
    @IBOutlet var button: UIButton!
    @IBOutlet var label: UILabel!
    
    @IBAction func buttonTapped(){
        self.ticker = field.text!
        StockApiCall{ (stockData) in
            DispatchQueue.main.async {
                let result = stockData.split(separator: "\"")
                let price = String(result[21]) as String
                self.label.text = "The current price of " + self.ticker.uppercased() + " is $" + price
            }
        }
    }
    
    func StockApiCall(_ callback: @escaping (String) -> ()) {
        let headers = [
            "X-RapidAPI-Key": "0c13cf9ad9msh86efdcbb1400cfbp1b3befjsn902ac8bd10bc",
            "X-RapidAPI-Host": "alpha-vantage.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://alpha-vantage.p.rapidapi.com/query?function=GLOBAL_QUOTE&symbol=" + self.ticker + "&datatype=json")! as URL, cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            }
            else {
                do {
                    let string = String(data: data!, encoding: .utf8)!
                    callback(string)
                }
                catch {
                    print("Error \(error)")
                }
                let httpResponse = response as? HTTPURLResponse
            }
        })
        dataTask.resume()
    }
}
