//
//  SenderChatTableViewCell.swift
//  PBNBChat
//
//  Created by Agstya Technologies on 15/03/19.
//  Copyright © 2019 PubNub. All rights reserved.
//

import UIKit

class SenderChatTableViewCell: UITableViewCell {

    // MARK:- IBOutlets | iVars
    @IBOutlet weak var viewBackgroundText: UIView!
    @IBOutlet weak var senderChatMessageLabel: UILabel!
    @IBOutlet weak var senderNameLabel: UILabel!
    
    // MARK:- View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK:- UI Methods
    private func setupUI() {
        viewBackgroundText.layer.masksToBounds = true
        viewBackgroundText.layer.cornerRadius = 10.0
    }
}
