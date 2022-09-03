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
    var ticker = "MSFT"

//    private let imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.backgroundColor = .white
//        return imageView
//    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        
        return tf
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Click for stock info", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    func StockApiCall(_ callback: @escaping (String) -> ()) {
        
        let headers = [
            "X-RapidAPI-Key": "0c13cf9ad9msh86efdcbb1400cfbp1b3befjsn902ac8bd10bc",
            "X-RapidAPI-Host": "alpha-vantage.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://alpha-vantage.p.rapidapi.com/query?function=GLOBAL_QUOTE&symbol=" + self.ticker + "&datatype=json")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
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

    override func viewDidLoad() {
        view.backgroundColor = .systemCyan
//        view.addSubview(imageView)
//
//        imageView.frame = CGRect(x: 0, y: 0, width: 350, height: 350)
//        imageView.center = view.center
        
        view.addSubview(button)
        
        getRandomPhoto()
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        view.addSubview(textField)
    }
    
    func setStockData(data: String) {
        self.stockData = data
    }

    
    @objc func didTapButton() {
        StockApiCall{ (stockData) in
            DispatchQueue.main.async {
                
            //let data = Data(stockData.utf8)
            var result = stockData.split(separator: "\"")
//                for i in 0..<result.count{
//                    print(i)
//                    print(result[i])
//
//                }
                var price = String(result[21]) as String
            self.textField.text = price
            
//
//                do {
//                    // make sure this JSON is in the format we expect
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        print(json)
//                        var str = json["Global Quote"] as! String
//                        var ch = Character(";")
//                        var result = str.split(seperator: ch)
//
//                        // try to read out a string array
//                        if let names = json["Global Quote"] as? [NSArray] {
//                            print(names)
//                        }
//                    }
//                } catch let error as NSError {
//                    print("Failed to load: \(error.localizedDescription)")
//                }
//
                //self.textField.text = result[6]
            }
        }
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        button.frame = CGRect(
            x: 30,
            y: view.frame.size.height-220-view.safeAreaInsets.bottom,
            width: view.frame.size.width-60,
            height: 60)
        
        textField.frame = CGRect(
            x: 130,
            y: view.frame.size.height-420-view.safeAreaInsets.bottom,
            width: view.frame.size.width-60,
            height: 60)
        
        
    }
    
    func getRandomPhoto() {
        let urlString =
            "https://source.unsplash.com/random/600x600"
        let url = URL(string: urlString)!
        guard let data = try? Data(contentsOf: url) else{
            return
        }
        //imageView.image = UIImage(data: data)
    }
}

