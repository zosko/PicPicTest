//
//  ModelFile.swift
//  testApp
//
//  Created by Bosko Petreski on 1/10/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit

class ModelFile: NSObject {
    var url : String = ""
    var id : String = ""
    var image : UIImage?
    
    func initFile(data : [String : Any]) -> ModelFile{
        self.id = data["id"] as! String
        
        API().GetEventFileURL(id: self.id) { (jsonData) in
            if(jsonData.keys.contains("url")){
                self.url = jsonData["url"] as! String
            }
        }
        
        API().GetEventFile(file_id: self.id, progress: { (progress) in
            print(progress)
        }) { (image) in
            self.image = image
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FileFetch"), object: nil, userInfo: ["file":self.id])
        }
        
        return self
    }
}
