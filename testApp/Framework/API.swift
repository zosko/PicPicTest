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

public typealias SuccessRespond = (([String:Any]) -> ())
public typealias FailedRespond = ((String) -> ())
public typealias SuccessImage = ((UIImage) -> ())
public typealias FailedImage = ((String) -> ())
public typealias ProgressDownload = ((Double) -> ())

class API: NSObject {
    
    static let shared = API()
    var server_ip : String = ""
    var server_port : Int = 0
    var token : String = ""
    
    func baseURL() -> String{
        return "http://" + API.shared.server_ip + ":\(API.shared.server_port)"
    }
    
    func get(params:[String:Any] = [:], path:String, success: @escaping SuccessRespond, failed: @escaping FailedRespond){
        let url : URL = URL(string: baseURL() + path)!
        
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: [:]).validate().responseJSON { (response) in
            
            switch response.result {
            case .success: success(response.value as! [String:Any])
            case let .failure(error): failed(error.localizedDescription)
            }
        }
    }
    
    func post(params:[String:Any] = [:], path:String, success: @escaping SuccessRespond, failed: @escaping FailedRespond){
        let url : URL = URL(string: baseURL() + path)!
        
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: [:]).validate().responseJSON { (response) in
            switch response.result {
            case .success: success(response.value as! [String:Any])
            case let .failure(error): failed(error.localizedDescription)
            }
        }
    }
    
    func download(params:[String:Any] = [:], path:String, progress: @escaping ProgressDownload, success: @escaping SuccessImage, failed: @escaping FailedImage){
        let url : URL = URL(string: baseURL() + path)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(params["name"] as! String)
            return (fileURL, [.createIntermediateDirectories])
        }
        
        Alamofire.download(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: [:], to: destination).downloadProgress { (progressDownload) in
            progress(progressDownload.fractionCompleted)
        }.responseData { (response) in
            if let data = response.value {
                let image = UIImage(data: data)
                success(image!)
            }
            else{
                failed(response.error!.localizedDescription)
            }
        }
    }
    
    func RequestToken(password: String, success: @escaping SuccessRespond, failed: @escaping FailedRespond){
        let params = ["password": MD5(password)]

        post(params: params, path: "/picpic/api/v1/tokens", success: { (response) in
            success(response)
        }) { (error) in
            failed(error)
        }
    }
    
    func GetEventStatus(success: @escaping SuccessRespond, failed: @escaping FailedRespond){
        let params = ["token": API.shared.token]
        
        get(params: params, path: "/picpic/api/v1/event/status", success: { (response) in
            success(response)
        }) { (error) in
            failed(error)
        }
    }
    
    func GetEventFiles(success: @escaping SuccessRespond, failed: @escaping FailedRespond){
        let params = ["token": API.shared.token]
        
        get(params: params, path: "/picpic/api/v1/event/files", success: { (response) in
            success(response)
        }) { (error) in
            failed(error)
        }
    }
    
    func GetEventFiles(from_id:String,success: @escaping SuccessRespond, failed: @escaping FailedRespond){
        let params = ["token": API.shared.token,
                      "from_id":from_id
        ]
        
        get(params: params, path: "/picpic/api/v1/event/files", success: { (response) in
            success(response)
        }) { (error) in
            failed(error)
        }
    }
    
    func GetEventFile(file_id:String, progress: @escaping ProgressDownload, success: @escaping SuccessImage, failed: @escaping FailedImage){
        let params = ["token": API.shared.token,
                      "name":file_id
        ]
        
        download(params: params, path: "/picpic/api/v1/event/files/\(file_id)", progress: { (progressDownload) in
            progress(progressDownload)
        }, success: { (image) in
            success(image)
        }) { (errorMessage) in
            failed(errorMessage)
        }
    }
}
