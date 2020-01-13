//
//  API.swift
//  testApp
//
//  Created by Bosko Petreski on 1/9/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit
import SwiftHash
import Alamofire

public typealias SuccessAPI = (([String:Any]) -> ())
public typealias SuccessImage = ((UIImage) -> ())
public typealias ProgressDownload = ((Double) -> ())

class API: NSObject {
    
    static let shared = API()
    var server_ip : String = ""
    var server_port : Int = 0
    var token : String = ""
    
    func baseURL() -> String{
        return "http://" + API.shared.server_ip + ":\(API.shared.server_port)"
    }
    
    func get(params:[String:Any] = [:], path:String, success: @escaping SuccessAPI){
        let url : URL = URL(string: baseURL() + path)!
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: [:]).validate().responseJSON { (response) in
            
            switch response.result {
            case .success:
                debugPrint("GET Response: \(response)")
                success(response.value as! [String:Any])
            case let .failure(error):
                debugPrint("GET Error: \(error)")
            }
        }
    }
    
    func post(params:[String:Any] = [:], path:String, success: @escaping SuccessAPI){
        let url : URL = URL(string: baseURL() + path)!
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: [:]).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                debugPrint("POST Response: \(response)")
                success(response.value as! [String:Any])
            case let .failure(error):
                debugPrint("POST Error: \(error)")
            }
        }
    }
    
    func download(params:[String:Any] = [:], path:String, progress: @escaping ProgressDownload, success: @escaping SuccessImage){
        let url : URL = URL(string: baseURL() + path)!
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        Alamofire.download(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: [:], to: destination).downloadProgress { (progressDownload) in
            progress(progressDownload.fractionCompleted)
        }.responseData { (response) in
            if let data = response.value {
                let image = UIImage(data: data)
                success(image!)
            }
        }
    }
    
    func RequestToken(password: String, success: @escaping SuccessAPI){
        let params = ["password": MD5(password)]
        post(params: params, path: "/picpic/api/v1/tokens") { (response) in
            success(response)
        }
    }
    
    func GetEventStatus(success: @escaping SuccessAPI){
        let params = ["token": API.shared.token]
        get(params: params, path: "/picpic/api/v1/event/status") { (response) in
            success(response)
        }
    }
    
    func GetEventFiles(success: @escaping SuccessAPI){
        let params = ["token": API.shared.token]
        get(params: params, path: "/picpic/api/v1/event/files") { (response) in
            success(response)
        }
    }
    
    func GetEventFiles(from_id:String,success: @escaping SuccessAPI){
        let params = ["token": API.shared.token,
                      "from_id":from_id
        ]
        get(params: params, path: "/picpic/api/v1/event/files") { (response) in
            success(response)
        }
    }
    
    func GetEventFile(file_id:String, progress: @escaping ProgressDownload, success: @escaping SuccessImage){
        let params = ["token": API.shared.token]
        download(params: params, path: "/picpic/api/v1/event/files/\(file_id)", progress: { (progressDownloaded) in
            progress(progressDownloaded)
        }) { (image) in
            success(image)
        }
    }
    
    func GetEventFileURL(id: String, success: @escaping SuccessAPI){
        let params = ["token": API.shared.token]
        get(params: params, path: "/picpic/api/v1/event/files/\(id)/url") { (response) in
            success(response)
        }
    }
    
    func GetCustomFile(id: String, lang:String, success: @escaping SuccessAPI){
        let params = ["token": API.shared.token,
                      "lang": lang
        ]
        get(params: params, path: "/picpic/api/v1/event/customFiles/\(id)") { (response) in
            success(response)
        }
    }
    
    func GetEventSettings(success: @escaping SuccessAPI){
        let params = ["token": API.shared.token]
        get(params: params, path: "/picpic/api/v1/event/settings") { (response) in
            success(response)
        }
    }
    
    func GetSurvey(success: @escaping SuccessAPI){
        let params = ["token": API.shared.token]
        get(params: params, path: "/picpic/api/v1/event/survey") { (response) in
            success(response)
        }
    }
    
    func PostSurveyAnswers(success: @escaping SuccessAPI){
        let params = ["token": API.shared.token]
        post(params: params, path: "/picpic/api/v1/event/survey") { (response) in
            success(response)
        }
        
//        {
//            id:[string], //Survey ID
//            type:[string], //Facebook | Twitter | Instagram | Weibo | Wechat | Email | MMS | Print
//            started:[datetime],
//            time_spent:[int]
//            answers: [
//                    {
//                        id:[string], //Question ID
//                        value:[string] //Text response, Option ID or comma separated Option IDs
//                    }
//            ]
//        }
    }
}
