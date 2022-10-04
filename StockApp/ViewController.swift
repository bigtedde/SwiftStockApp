/**
 ViewController.swift
 StockApp
 Created by Theodore Lawson on 9/1/22.
*/

import UIKit
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet var field: UITextField!
    @IBOutlet var button: UIButton!
    @IBOutlet var leftLabel: UILabel!
    @IBOutlet var rightLabel: UILabel!
    @IBOutlet var outputLabel: UILabel!
    var ticker: String!
        
    //Main app feature - handles API call and displays stock data.
    @IBAction func buttonTapped(){
        self.outputLabel.text = "Loading..."
        setTicker(userTicker: field.text!)
        
        //Calls the API, handles and formats the data, displays data in app.
        StockApiCall{ (stockData)
            in DispatchQueue.main.async {
                let dataDict = self.stringToDictionary(data: stockData)
                self.displayStockData(dataDict: dataDict)
            }
        }
    }
    
    //Formats the stock data that is stored in the dictionary
    func displayStockData(dataDict: Dictionary<String , String>) {
        var stockKeys = ""
        var stockValues = ""
        let notFound = "---\n"
        
        /**
        Starts listing data in the order we want it dispayed, with most important data first.
        Always displays the keys, but will only display values if they contain valid data.
        */
        
        //Display current stock price data
        stockKeys += "Current price: \n"
        if dataDict.keys.contains("price"){
            let priceDouble = Double(round((Double(dataDict["price"]!)! * 100)) / 100.0)
            let priceString = "$" + String(format: "%.2f", priceDouble)
            stockValues += priceString + "\n"
        } else{
            stockValues += notFound
        }
        
        //Displays todays change data in $ and %
        stockKeys += "Today's change: \n"
        if dataDict.keys.contains("change") && dataDict.keys.contains("change percent"){
            
            //start by getting change in $
            let changeDouble = Double(round((Double(dataDict["change"]!)! * 100)) / 100.0)
            var changeString: String!
            if changeDouble >= 0{
                changeString = "+$" + String(format: "%.2f", changeDouble)
            } else {
                changeString = "-$" + String(format: "%.2f", changeDouble).replacingOccurrences(of: "-", with: "")
            }
            
            //now we get change in %
            let trimPercent = String(dataDict["change percent"]!).replacingOccurrences(of: "%", with: "")
            let percentChangeDouble = Double(round((Double(trimPercent)! * 100)) / 100)
            var percentChangeString: String!
            if percentChangeDouble >= 0 {
                percentChangeString = "+" + String(format: "%.2f", percentChangeDouble) + "%"
            } else{
                percentChangeString = String(format: "%.2f", percentChangeDouble) + "%"
            }
            
            stockValues += changeString + " (" + percentChangeString + ")\n"
            
        }
        else{
            stockValues += notFound
        }
        
        //Display previous close data
        stockKeys += "Previous close: \n"
        if dataDict.keys.contains("previous close"){
            let closeDouble = Double(round((Double(dataDict["previous close"]!)! * 100)) / 100.0)
            let closeString = "$" + String(format: "%.2f", closeDouble)
            stockValues += closeString + "\n"
        }
        else{
            stockValues += notFound
        }
        
        
        //displays today's open data
        stockKeys += "Today's open: \n"
        if dataDict.keys.contains("open"){
            let openDouble = Double(round((Double(dataDict["open"]!)! * 100)) / 100.0)
            let openString = "$" + String(format: "%.2f", openDouble)
            stockValues += openString + "\n"
        }
        else{
            stockValues += notFound
        }
        
        //Displays today's high data
        stockKeys += "Today's high: \n"
        if dataDict.keys.contains("high"){
            let highDouble = Double(round((Double(dataDict["high"]!)! * 100)) / 100.0)
            let highString = "$" + String(format: "%.2f", highDouble)
            stockValues += highString + "\n"
        }
        else{
            stockValues += notFound
        }
        
        //Displays today's low data
        stockKeys += "Today's low: \n"
        if dataDict.keys.contains("low"){
            let lowDouble = Double(round((Double(dataDict["low"]!)! * 100)) / 100.0)
            let lowString = "$" + String(format: "%.2f", lowDouble)
            stockValues += lowString + "\n"
        }
        else{
            stockValues += notFound
        }
        
        //Displays todays trading volume data
        stockKeys += "Trade Volume: \n"
        if dataDict.keys.contains("volume"){
            let volumeDouble = Double(dataDict["volume"]!)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let volumeString = numberFormatter.string(from: NSNumber(value:volumeDouble!))
            stockValues += volumeString! + "\n"
        }
        else{
            stockValues += notFound
        }
        
        //Displays the latest trading day data
        stockKeys += "Latest trading day: \n"
        if dataDict.keys.contains("latest trading day"){
            let pivot = dataDict["latest trading day"]!.firstIndex(of: "-") ??
                        dataDict["latest trading day"]!.endIndex
            var yearTrimmed = dataDict["latest trading day"]![pivot...]
            yearTrimmed.removeFirst()
            let stringLastTradeDay = yearTrimmed.replacingOccurrences(of: "-", with: "/")
            stockValues += stringLastTradeDay + "\n"
        }
        else{
            stockValues += notFound
        }
        
        //Display formatted information on the screen.
        if dataDict.isEmpty {
            self.outputLabel.text = self.getTicker().uppercased() + " - Not a valid stock ticker."
        }
        else {
            self.outputLabel.text = self.getTicker().uppercased()
        }
        self.leftLabel.text = stockKeys
        self.rightLabel.text = stockValues
        self.field.text = ""
    }
    
    func stringToDictionary(data: String) -> Dictionary<String, String>{
        var dataDict: [String: String] = [:]
        let dataArray = data.split(separator: "\n")
        for line in dataArray{
            let dataPair = line.split(separator: ":")
            
            //for each time of data that contains a key and value, trim the data down to the values.
            //Specific to this API, kinda janky approach, will work to improve.
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
                
                //Puts all valid key/value pairs into the dictionary
                if finalKey != ("") {
                    dataDict[String(finalKey)] = String(finalValue)
                }
            }
        }
        
        //Print data to console for review.
        for data in dataDict{
            print(data)
        }
        
        return dataDict
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
