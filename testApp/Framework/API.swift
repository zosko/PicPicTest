//
//  API.swift
//  testApp
//
//  Created by Bosko Petreski on 1/9/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit
import SwiftHash

public typealias SuccessAPI = (([String:Any]) -> ())

class API: NSObject {
    
    static let shared = API()
    var server_ip : String = ""
    var server_port : Int = 0
    var token : String = ""
    
    func get(url:URL, success: @escaping SuccessAPI){
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            do{
                let jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                success(jsonData)
            }
            catch{
                print("Error json serialization")
            }
        }
        task.resume()
    }
    
    func post(url:URL, success: @escaping SuccessAPI){

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            do{
                let jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                success(jsonData)
            }
            catch{
                print("Error json serialization")
            }
        }

        task.resume()
    }
    
    func getToken(password: String, success: @escaping SuccessAPI){
        var components = URLComponents(string: "http://" + API.shared.server_ip + ":\(API.shared.server_port)" + "/picpic/api/v1/tokens")!
        components.queryItems = [
            URLQueryItem(name: "password", value: MD5(password))
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")

        post(url: components.url!) { (jsonData) in
            success(jsonData)
        }
    }
    
    func getEventsFiles(success: @escaping SuccessAPI){
        var components = URLComponents(string: "http://" + API.shared.server_ip + ":\(API.shared.server_port)" + "/picpic/api/v1/event/files")!
        components.queryItems = [
            URLQueryItem(name: "token", value: API.shared.token)
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")

        get(url: components.url!) { (jsonData) in
            success(jsonData)
        }
        
    }
    
    func getFileURL(id: String, success: @escaping SuccessAPI){
        var components = URLComponents(string: "http://" + API.shared.server_ip + ":\(API.shared.server_port)" + "/picpic/api/v1/event/files/\(id)/url")!
        components.queryItems = [
            URLQueryItem(name: "token", value: API.shared.token)
        ]
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")

        get(url: components.url!) { (jsonData) in
            success(jsonData)
        }
        
    }
}
