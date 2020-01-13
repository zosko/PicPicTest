//
//  ViewController.swift
//  testApp
//
//  Created by Bosko Petreski on 1/9/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tblFiles : UITableView!
    
    var broadcastConnection: UDPBroadcastConnection!
    var arrFiles : [ModelFile] = []
    
    @IBAction func login(_ sender: AnyObject) {
        do {
            try broadcastConnection.sendBroadcast("qya2342tzt1yl")
        } catch {
            print("Error: \(error)\n")
        }
    }
    
    func getFiles(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        API().GetEventFiles { (jsonData) in
            let arrTmp = jsonData["files"] as! [Any]
            
            for files in arrTmp{
                self.arrFiles.append(ModelFile().initFile(data: files as! Dictionary))
            }

            OperationQueue.main.addOperation {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.tblFiles.reloadData()
            }
            
        }
    }
    
    //MARK: TableViewDelegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath)
        
        let modelFile : ModelFile = arrFiles[indexPath.row]
        
        cell.textLabel!.text = modelFile.id
        
        cell.imageView?.image = modelFile.image;
        
//        cell.imageView?.sd_setImage(with: URL(string: modelFile.url), placeholderImage: UIImage.init(), options:SDWebImageOptions.progressiveLoad, completed: { (image, error, type, url) in
//            self.tblFiles.reloadRows(at: [indexPath], with: .fade)
//        })
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let modelFile : ModelFile = arrFiles[indexPath.row]
        UIApplication.shared.open(URL(string: modelFile.url)!, options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "FileFetch"), object: nil, queue: .main) { (notification) in
            
            let file_id = notification.userInfo?["file"] as! String
            
            for files in self.arrFiles{
                let index = self.arrFiles.firstIndex(where: {$0 == files})!
                
                if(files.id == file_id){
                    self.tblFiles.reloadRows(at: [(NSIndexPath.init(row: index, section: 0) as IndexPath)], with: .fade)
                }
            }
            
        }
        
        
        do {
            broadcastConnection = try UDPBroadcastConnection(
                port: 19890,
                handler: { (ipAddress: String, port: Int, response: Data) -> Void in
                    API.shared.server_ip = ipAddress
                    API.shared.server_port = 80
                    
                    self.showLogin { (password) in
                        MBProgressHUD.showAdded(to: self.view, animated: true)
                        API().RequestToken(password: password) { (jsonData) in
                            if(jsonData.keys.contains("token")){
                                API.shared.token = jsonData["token"] as! String
                                print(API.shared.token)
                                
                                OperationQueue.main.addOperation {
                                    MBProgressHUD.hide(for: self.view, animated: true)
                                    self.getFiles()
                                }
                            }
                            else{
                                self.showMessage(message: "Invalid password")
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

