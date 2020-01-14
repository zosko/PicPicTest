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
    
    //MARK: IBOutlets
    @IBOutlet var tblFiles : UITableView!
    
    //MARK: Variables
    var checkTimerEvent : Timer!
    var broadcastConnection: UDPBroadcastConnection!
    var arrFiles : [ModelFile] = []
    
    //MARK: CustomFunctions
    @objc func checkEventStatus(){
        
        //    [
        //    "last_settings_change": 2020-01-14T18:04:30.4111905Z,
        //    "id": edf0f787-52cc-487b-9981-fddcd1d703eb,
        //    "status": started,
        //    "last_status_change": 2020-01-14T18:04:30.4111905Z,
        //    "name": Sample Event,
        //    "file_count": 35
        //    ]
        
        API().GetEventStatus(success: { (jsonData) in
            print(jsonData)
        }) { (errorMessage) in
            print(errorMessage)
        }
    }
    
    func getFiles(){
        MBProgressHUD.showAdded(to: self.view, animated: true)

        API().GetEventFiles(success: { (jsonData) in
            let arrTmp = jsonData["files"] as! [Any]
            
            for files in arrTmp{
                self.arrFiles.append(ModelFile().initFile(data: files as! Dictionary))
            }

            MBProgressHUD.hide(for: self.view, animated: true)
            self.tblFiles.reloadData()
            
            //self.checkTimerEvent = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkEventStatus), userInfo: nil, repeats: true)
            
        }) { (errorMessage) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showMessage(message: errorMessage)
        }
    }
    
    //MARK: IBActions
    @IBAction func login(_ sender: AnyObject) {
        do {
            try broadcastConnection.sendBroadcast("qya2342tzt1yl")
        } catch {
            print("Error: \(error)\n")
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
        
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let fileURL = documentsURL.appendingPathComponent(modelFile.id)
//
//        cell.imageView?.sd_setImage(with: fileURL, placeholderImage: UIImage.init(), options:SDWebImageOptions.progressiveLoad, completed: { (image, error, type, url) in
//            self.tblFiles.reloadRows(at: [indexPath], with: .fade)
//        })
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let modelFile : ModelFile = arrFiles[indexPath.row]
        print(modelFile)
    }
    
    //MARK: UIViewControllerDelegates
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if(Database.shared.allElements().count > 0){
            for fileName in Database.shared.allElements(){
                self.arrFiles.append(ModelFile().initDownloadedFile(name: fileName as! String))
            }
            tblFiles.reloadData()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "FileFetch"), object: nil, queue: .main) { (notification) in
            
            let file_id = notification.userInfo?["file"] as! String
            
            for files in self.arrFiles{
                if(files.id == file_id){
                    let index = self.arrFiles.firstIndex(where: {$0 == files})!
                    self.tblFiles.reloadRows(at: [(NSIndexPath.init(row: index, section: 0) as IndexPath)], with: .fade)
                    break
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
                        
                        API().RequestToken(password: password, success: { (jsonData) in
                            MBProgressHUD.hide(for: self.view, animated: true)
                            if(jsonData.keys.contains("token")){
                                API.shared.token = jsonData["token"] as! String
                                self.getFiles()
                            }
                            else{
                                self.showMessage(message: "Invalid password")
                            }
                        }) { (errorMessage) in
                            MBProgressHUD.hide(for: self.view, animated: true)
                            self.showMessage(message: errorMessage)
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

