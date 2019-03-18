//
//  Validation.swift
//  TheChat
//
//  Created by Agstya - Something New on 18/07/18.
//  Copyright © 2018 Agstya Technologies. All rights reserved.
//

import Foundation

struct Validation {
    
    static func isStringEmpty(_ theString: String?) -> Bool {
        if theString != nil {
            let str = theString!.trimmingCharacters(in: .whitespaces)
            
            if str.count == 0 {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
}

extension UIViewController {
    func showOKAlert(strMessage: String) {
        let actionOK = UIAlertAction(title: "OK", style: .default) { (theAction) in
            
        }
        
        let theAlertController = UIAlertController(title: "", message: strMessage, preferredStyle: .alert)
        theAlertController.addAction(actionOK)
        
        self.present(theAlertController, animated: true, completion: nil)
    }
    
    
    func showOKWithTxtFldAlert(strMessage: String, completionBlock: @escaping (String) -> Void) {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "", message: "Enter Your Name", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Your Name"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            completionBlock(textField?.text ?? "")
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
}
