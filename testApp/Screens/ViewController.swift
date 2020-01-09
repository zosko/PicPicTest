//
//  ViewController.swift
//  testApp
//
//  Created by Bosko Petreski on 1/9/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    @IBOutlet var imgPreview : UIImageView!
    
    var broadcastConnection: UDPBroadcastConnection!
    
    @IBAction func login(_ sender: AnyObject) {
        do {
            try broadcastConnection.sendBroadcast("qya2342tzt1yl")
        } catch {
            print("Error: \(error)\n")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            broadcastConnection = try UDPBroadcastConnection(
                port: 19890,
                handler: { (ipAddress: String, port: Int, response: Data) -> Void in
                    API.shared.server_ip = ipAddress
                    API.shared.server_port = 80
                    print("UDP connection \(API.shared.server_ip):\(API.shared.server_port)")
                    
                    API().getToken(password: "bosko123") { (jsonData) in
                        API.shared.token = jsonData["token"] as! String
                        print(API.shared.token)
                        
                        API().getEventsFiles { (jsonData) in
                            let arrFiles = jsonData["files"] as! [Any]
                            
                            let file = arrFiles.first as! [String:Any]
                            print(file)
                            
                            API().getFileURL(id: file["id"] as! String) { (jsonData) in

                                let urlFile = jsonData["url"] as! String
                                print(urlFile)
                                
                                self.imgPreview.sd_setImage(with: URL(string: urlFile), completed: nil)
                            }
                        }
                    }
                },
                errorHandler: { (error) in
                    print("Error: \(error)\n")
            })
        } catch {
            print("Error: \(error)\n")
        }
    }


}

