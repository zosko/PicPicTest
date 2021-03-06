//
//  Database.swift
//  testApp
//
//  Created by Bosko Petreski on 1/14/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit

class Database: NSObject {
    var jsonDatabase: NSMutableArray
    
    static var shared: Database = {
        let instance = Database()
        
        return instance
    }()
    
    private func pathDatabase() -> String{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("database.plist")
        return fileURL.path
    }
    
    func containElement(element: String) -> Bool{
        return jsonDatabase.contains(element)
    }
    
    func saveElement(element:String){
        jsonDatabase.add(element)
        (jsonDatabase as NSArray).write(toFile: pathDatabase(), atomically: true)
    }
    
    func allElements() -> NSArray{
        return jsonDatabase
    }
    
    func cleanElements() -> Void{
        jsonDatabase = NSMutableArray.init()
        (jsonDatabase as NSArray).write(toFile: pathDatabase(), atomically: true)
    }
    
    private override init() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("database.plist")
        
        jsonDatabase = NSMutableArray(contentsOf: fileURL) ?? NSMutableArray.init()

        super.init()
    }
}
