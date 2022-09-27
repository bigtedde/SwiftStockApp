//  ViewController.swift
//  StockApp
//
//  Created by Theodore Lawson on 9/1/22.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet var field: UITextField!
    @IBOutlet var button: UIButton!
    @IBOutlet var leftLabel: UILabel!
    @IBOutlet var rightLabel: UILabel!
    @IBOutlet var outputLabel: UILabel!
    var ticker: String!
    var stockDataString: String!
        
    @IBAction func buttonTapped(){
        self.outputLabel.text = "Loading..."
        setTicker(userTicker: field.text!)
        
        StockApiCall{ (stockData)
            in DispatchQueue.main.async {
                self.setStockDataString(data: stockData)
                let dataDict = self.stringToDictionary(data: stockData)
                self.leftLabel.text = self.printDataDictKeys(dataDict: dataDict)
                self.rightLabel.text = self.printDataDictValues(dataDict: dataDict)
                // self.outputLabel.text = "Current Price: " + String(self.getPrice(dataDict: dataDict) ?? "")
            }
        }
    }
    
    func printDataDictKeys(dataDict: Dictionary<String , String>) -> String {
        var stockData = ""
        
        for keys in dataDict.keys{
            stockData = stockData + keys.capitalized + "\n"
        }
        
        return stockData
    }
    
    func printDataDictValues(dataDict: Dictionary<String , String>) -> String {
        var stockData = ""
        
        for values in dataDict.values{
            stockData = stockData + values + "\n"
        }
        
        return stockData
    }
    
    func getPrice(dataDict: Dictionary<String, String>) -> String? {
        if dataDict.keys.contains("price"){
            let priceData: String!
            priceData = dataDict["price"]
            return priceData
        }
        else{
            return("NO PRICE DATA!")
        }
    }
    
    func stringToDictionary(data: String) -> Dictionary<String, String>{
        var dataDict: [String: String] = [:]
        var dataArray = data.split(separator: "\n")
        for line in dataArray{
            var dataPair = line.split(separator: ":")
            
            //for each time of data that contains a key and value, trim the data down to the values
            if dataPair.count == 2{
                
                //Starting with the keys, trim away the unnecessary characters
                var pivot = dataPair[0].firstIndex(of: ".") ?? dataPair[0].endIndex
                var rightSide = dataPair[0][pivot...]
                var leftTrim = rightSide.replacingOccurrences(of: ". ", with: "")
                let finalKey = leftTrim.replacingOccurrences(of: "\"", with: "")
                
                //Now trim the data on the values
                pivot = dataPair[1].firstIndex(of: "\"") ?? dataPair[1].endIndex
                rightSide = dataPair[1][pivot...]
                leftTrim = rightSide.replacingOccurrences(of: "\",", with: "")
                let finalValue = leftTrim.replacingOccurrences(of: "\"", with: "")
                
                if finalKey != ("") {
                    dataDict[String(finalKey)] = String(finalValue)
                }
            }
        }
        
        for data in dataDict{
            print(data)
        }
            return dataDict
    }
    
    
    //Stores data from original API call
    func setStockDataString(data: String) {
        self.stockDataString = data
    }
    
    //Returns the original data from API call
    func getStockDataString() -> String {
        return self.stockDataString
    }
    
    //Gets the most recent ticker the user requested
    func getTicker() -> String {
        return self.ticker
    }
    
    //Sets the ticker to what the user has entered
    func setTicker(userTicker: String){
        self.ticker = userTicker
    }
    
    //Gathers stock data by calling the Alpha Advantage API
    func StockApiCall(_ callback: @escaping (String) -> ()) {
        let headers = [
            "X-RapidAPI-Key": "0c13cf9ad9msh86efdcbb1400cfbp1b3befjsn902ac8bd10bc",
            "X-RapidAPI-Host": "alpha-vantage.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string:
            "https://alpha-vantage.p.rapidapi.com/query?function=GLOBAL_QUOTE&symbol="
            + self.getTicker() + "&datatype=json")! as URL, cachePolicy:
            .useProtocolCachePolicy,timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let dataTask = session.dataTask (with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            if let error = error {
                print(error)
            }
            else if let data = data {
                let stockDataOriginal = String(data: data, encoding: .utf8)!
                callback(stockDataOriginal)
            }
            let httpResponse = response as? HTTPURLResponse
            
        })
        dataTask.resume()
    }
}
