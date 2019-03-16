//
//  Validation.swift
//  TheChat
//
//  Created by Agstya - Something New on 18/07/18.
//  Copyright © 2018 Agstya Technologies. All rights reserved.
//

import Foundation

struct Validation {
    static func isValidEmailAddress(strEmail: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: strEmail)
    }
    
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
    
    static func stringValueForTheObject(theValue: Any?) -> String {
        var strValue: String = ""
        
        guard theValue != nil else {
            return strValue
        }
        
        guard !(theValue is NSNull) else {
            return strValue
        }
        
        if ((theValue as? NSNumber) != nil) {
            let theInt = Int(truncating: theValue as! NSNumber)
            strValue  = String(theInt)
        } else {
            if ((theValue as? String) != nil) {
                strValue = theValue as! String
            }
        }
        
        return strValue
    }
    
    static func stringUptoIndex(theString: String, index: Int, isUpperCased: Bool) -> String {
        if theString.count > index {
            var strFinal = ""
            
            for (charIndex, theValue) in theString.enumerated() {
                if charIndex < index {
                    strFinal.append(theValue)
                } else {
                    break
                }
            }
            
            return (isUpperCased ? strFinal.uppercased() : strFinal)
        }
        
        return ""
    }
}

extension NSNumber {
    func convertToString() -> String {
        return String(format: "%@", self)
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
    
    
    func showYesOrNoAlert(strMessage: String, completionBlock: @escaping (Bool) -> Void) {
        let actionYes = UIAlertAction(title: "Yes", style: .default) { (theAction) in
            completionBlock(true)
        }
        
        let actionNo = UIAlertAction(title: "No", style: .default) { (theAction) in
            completionBlock(false)
        }
        
        let theAlertController = UIAlertController(title: "", message: strMessage, preferredStyle: .alert)
        theAlertController.addAction(actionYes)
        theAlertController.addAction(actionNo)
        
        self.present(theAlertController, animated: true, completion: nil)
    }
}
