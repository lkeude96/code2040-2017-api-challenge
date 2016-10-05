//
//  ViewController.swift
//  CODE2040APIChallenge
//
//  Created by Eude Lesperance on 9/19/16.
//  Copyright © 2016 Eude Lesperance. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let apiToken = "0fad65b9f50d5b3d945b875553145f64"
    let baseEndpoint = "http://challenge.code2040.org/api/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        register()
        reverseString()
        haystack()
        prefix()
        dating()
    }
    
    func register() {
        let github = "https://github.com/lkeude96/code2040-2017-api-challenge"
        postRequest("/register", params: ["token": apiToken as AnyObject, "github": github as AnyObject]) { (data) in
            print(String(data: data, encoding: String.Encoding.utf8))
            
        }
    }
    
    func reverseString() {
        postRequest("/reverse", params: ["token": apiToken as AnyObject]) { (data) in
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                let reversedString = self.reverse(string: string)
                self.postRequest("/reverse/validate", params: ["token": self.apiToken as AnyObject, "string": reversedString as AnyObject]) { (data) in
                    print(String(data: data, encoding: String.Encoding.utf8))
                }
            }
        }
    }
    
    func reverse(string: String) -> String {
        var reverseString = ""
        for i in stride(from: string.characters.count - 1, to: -1, by: -1) {
            reverseString.append(string[string.index(string.startIndex, offsetBy: i)])
        }
        return reverseString
    }
    
    func haystack() {
        postRequest("/haystack", params: ["token": apiToken as AnyObject]) { (data) in
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject> {
                    if let needle = dictionary["needle"] as? String, let haystack = dictionary["haystack"] as? [String] {
                        let index = self.locate(needle: needle, haystack: haystack)
                        self.postRequest("/haystack/validate", params: ["token": self.apiToken as AnyObject, "needle": index as AnyObject]) { (data) in
                            print(String(data: data, encoding: String.Encoding.utf8))
                        }
                    }
                }
            } catch {
                print("Wasn't able to serialize haystack json")
            }
        }
    }
    
    func locate(needle: String, haystack: [String]) -> Int {
        for i in 0..<haystack.count {
            if haystack[i] == needle {
                return i
            }
        }
        
        return -1
    }
    
    func prefix() {
        postRequest("/prefix", params: ["token": apiToken as AnyObject]) { (data) in
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject> {
                    if let prefix = dictionary["prefix"] as? String,
                        let array = dictionary["array"] as? [String] {
                        let parsed = self.removeStrings(withPrefix: prefix, from: array)
                        self.postRequest("/prefix/validate", params: ["token": self.apiToken as AnyObject, "array": parsed as AnyObject]) { (data) in
                            print(String(data: data, encoding: String.Encoding.utf8))
                        }
                    }
                }
                
            } catch {
                
            }
        }
    }
    
    func removeStrings(withPrefix prefix: String, from array: [String]) -> [String] {
        var parsed = [String]()
        for string in array {
            if !string.hasPrefix(prefix) {
                parsed.append(string)
            }
        }
        return parsed
    }
    
    func dating() {
        postRequest("/dating", params: ["token": apiToken as AnyObject]) { (data) in
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject> {
                    if let datestamp = dictionary["datestamp"] as? String,
                        let interval = dictionary["interval"] as? Int {
                        let newDate = self.dateString(from: datestamp, with: interval)
                        self.postRequest("/dating/validate", params: ["token": self.apiToken as AnyObject, "datestamp": newDate as AnyObject]) { (data) in
                            print(String(data: data, encoding: String.Encoding.utf8))
                        }
                        
                    }
                }
                
            } catch {
                
            }
        }
    }
    
    func dateString(from datestamp: String, with interval:Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        let initialDate = dateFormatter.date(from: datestamp)
        let newDate = initialDate?.addingTimeInterval(TimeInterval(interval))
        
        return dateFormatter.string(from: newDate!)
    }

    func postRequest(_ endpoint: String, params:[String: AnyObject], completion: ((_ data: Data) -> ())?) {
        let url = URL(string: baseEndpoint + endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                completion?(data)
            }
        }
        
        task.resume()
    }
}

