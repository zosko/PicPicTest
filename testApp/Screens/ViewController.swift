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
    @IBOutlet var btnLogin : UIButton!
    
    //MARK: Variables
    var checkTimerEvent : Timer!
    var broadcastConnection: UDPBroadcastConnection!
    var arrFiles : [ModelFile] = []
    var lastFileID = ""
    var lastFileCount = 0
    var file_count = 0
    var hudLogin : MBProgressHUD?
    var oneShot : DispatchSourceTimer!
    
    //MARK: CustomFunctions
    @objc func checkEventStatus(){
        API().GetEventStatus(success: { (jsonData) in
            
            if jsonData.keys.count > 0 {
                self.file_count = jsonData["file_count"] as! Int
                
                if self.lastFileCount < self.file_count {
                    self.getNextFiles()
                }
            }
            
        }) { (errorMessage) in
            print(errorMessage)
        }
    }
    @objc func refreshTable(sender: UIRefreshControl) {
        sender.endRefreshing()
        getFirstFiles()
    }
    func getFirstFiles(){
        
        self.arrFiles = []
        self.tblFiles.reloadData()
        Database.shared.cleanElements()
        file_count = 0
        lastFileCount = 0
        lastFileID = ""
        
        MBProgressHUD.showAdded(to: self.view, animated: true)

        API().GetEventFiles(success: { (jsonData) in
            let allElements = jsonData["files"] as! [Any]
            
            var first10: [Any] = allElements
            
            if allElements.count > 10{
                first10 = Array(allElements[0..<10])
            }
            
            for files in first10{
                self.arrFiles.append(ModelFile().initFile(data: files as! Dictionary))
            }
            
            self.lastFileCount = self.arrFiles.count
            if(self.lastFileCount > 0){
                self.lastFileID = self.arrFiles.last!.id
            }

            MBProgressHUD.hide(for: self.view, animated: true)
            self.tblFiles.reloadData()
            
        }) { (errorMessage) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showMessage(message: errorMessage)
        }
    }
    func getNextFiles(){
        MBProgressHUD.showAdded(to: self.view, animated: true)

        API().GetEventFiles(from_id: lastFileID, success: { (jsonData) in
            let allElements = jsonData["files"] as! [Any]
            
            var first10: [Any] = allElements
            
            if allElements.count > 10{
                first10 = Array(allElements[0..<10])
            }
            
            for files in first10{
                self.arrFiles.append(ModelFile().initFile(data: files as! Dictionary))
            }
            
            self.lastFileID = self.arrFiles.last!.id
            self.lastFileCount = self.arrFiles.count
            
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tblFiles.reloadData()
            
        }) { (errorMessage) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showMessage(message: errorMessage)
        }
    }
    
    //MARK: IBActions
    @IBAction func login(_ sender: AnyObject) {
        do {
            try broadcastConnection.sendBroadcast("qya2342tzt1yl")
            hudLogin = MBProgressHUD.showAdded(to: self.view, animated: true)
            
            oneShot = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
            oneShot.schedule(deadline: .now() + 2)
            oneShot.setEventHandler {
                self.hudLogin?.hide(animated: false)
                self.showMessage(message: "Try again")
            }
            oneShot.activate()
        } catch {
            hudLogin?.hide(animated: false)
            self.showMessage(message: error.localizedDescription)
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
        
//        cell.imageView?.image = modelFile.image;
        cell.imageView?.sd_setImage(with: modelFile.url, completed: nil)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let modelFile : ModelFile = arrFiles[indexPath.row]
        let controller = UIActivityViewController(activityItems: [modelFile.image!], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
        if let popOver = controller.popoverPresentationController {
            popOver.sourceView = self.btnLogin
            popOver.sourceRect = CGRect(x: 0, y: 0, width: 200, height: 200)
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = arrFiles.count - 1
        
        if indexPath.row == lastElement && lastFileCount < file_count {
            //getNextFiles()
        }
    }
    
    //MARK: UIViewControllerDelegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable(sender:)), for: .valueChanged)
        tblFiles.addSubview(refreshControl)
                
        if(Database.shared.allElements().count > 0){
            for fileName in Database.shared.allElements(){
                self.arrFiles.append(ModelFile().initDownloadedFile(name: fileName as! String))
            }
            lastFileID = arrFiles.last!.id
            lastFileCount = arrFiles.count
            file_count = lastFileCount
            tblFiles.reloadData()
        }
        
        NotificationCenter.default.addObserver(forName: Notifications.DidFileDownloaded, object: nil, queue: .main) { (notification) in
            
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
                    let server: [String:Any] = try! JSONSerialization.jsonObject(with: response, options: .allowFragments) as! [String : Any]
                    self.hudLogin?.hide(animated: false)
                    self.oneShot.cancel()
                    
                    API.shared.server_ip = server["ip"] as! String
                    API.shared.server_port = server["port"] as! Int
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.showLogin { (password) in

                        API().RequestToken(password: password, success: { (jsonData) in
                            MBProgressHUD.hide(for: self.view, animated: true)
                            self.btnLogin.isHidden = true
                            
                            API.shared.token = jsonData["token"] as! String

                            self.checkTimerEvent = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.checkEventStatus), userInfo: nil, repeats: true)

                            if(Database.shared.allElements().count > 0){
                                self.getNextFiles()
                            }
                            else{
                                self.getFirstFiles()
                            }
                        }) { (errorMessage) in
                            MBProgressHUD.hide(for: self.view, animated: true)
                            self.showMessage(message: errorMessage)
                        }
                    }
                },
                errorHandler: { (error) in
                    self.hudLogin?.hide(animated: false)
                    self.showMessage(message: error.localizedDescription)
            })
        } catch {
            self.showMessage(message: error.localizedDescription)
        }
    }


}

