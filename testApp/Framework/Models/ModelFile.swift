//
//  ModelFile.swift
//  testApp
//
//  Created by Bosko Petreski on 1/10/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit

class ModelFile: NSObject {
    var id : String = ""
    var image : UIImage?
    
    private func getPathDirectory(name:String) -> String{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(name)
        return fileURL.path
    }
    
    func initDownloadedFile(name : String ) -> ModelFile{
        self.id = name
        self.image = UIImage(contentsOfFile: getPathDirectory(name: name))
        return self
    }
    
    func initFile(data : [String : Any]) -> ModelFile{
        self.id = data["id"] as! String
        
        if !Database.shared.containElement(element: self.id){
            API().GetEventFile(file_id: self.id, progress: { (progress) in

            }, success: { (image) in
                self.image = image
                Database.shared.saveElement(element:self.id)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FileFetch"), object: nil, userInfo: ["file":self.id])
            }) { (errorMessage) in
                Database.shared.saveElement(element:self.id)
                self.image = UIImage(contentsOfFile: self.getPathDirectory(name: self.id))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FileFetch"), object: nil, userInfo: ["file":self.id])
            }
        }
        
        
        
        return self
    }
}
