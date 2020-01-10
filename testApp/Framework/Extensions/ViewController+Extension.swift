//
//  ViewController+Extension.swift
//  testApp
//
//  Created by Bosko Petreski on 1/10/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit

public typealias AlertBlockOK = ((String) -> ())

extension ViewController{
    func showLogin(password: @escaping AlertBlockOK){
        let alert = UIAlertController.init(title: "Password", message: "Enter password", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "password"
        }
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action) in
            password((alert.textFields?.first!.text)!)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true)
    }
    func showMessage(message: String){
        let alert = UIAlertController.init(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true)
    }
}
