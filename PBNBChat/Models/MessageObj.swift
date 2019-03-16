//
//  MessageObj.swift
//  PBNBChat
//
//  Created by Agstya Technologies on 15/03/19.
//  Copyright © 2019 PubNub. All rights reserved.
//

import UIKit

class MessageObj {
    
    var messageString: String!
    var senderName: String!
    var senderUUID: String!
    
    func setData(messageString: String, senderName: String, senderUUID: String) {
        self.messageString     = messageString
        self.senderName   = senderName
        self.senderUUID       = senderUUID
    }

}
