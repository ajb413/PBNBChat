//
//  SingleChatViewController.swift
//  TheChat
//
//  Created by Agstya - Something New on 20/07/18.
//  Copyright © 2018 Agstya Technologies. All rights reserved.
//

import UIKit
import PubNub

class SingleChatViewController: UIViewController, PNObjectEventListener {
    
    // PubNub
    var client: PubNub!
    
    let PUBLISH_KEY = "pub-c-76c815f9-51e4-4565-898e-24555268e619"
    let SUBSCRIBE_KEY = "sub-c-99153532-457d-11e9-8534-9add990cf553"
    let CHANNEL_NAME = "chat_channel"
    
    
    // Others
    var strChatID: String = ""
    var currentUUID: String = ""
    var currentUserName: String = ""
    var arrFetchedChatMessages = [MessageObj]()
    var totalMessagesCount = 0
    
    // MARK:- IBOutlets | Variables -
    @IBOutlet weak var tblViewSingleChat: UITableView!
    @IBOutlet weak var txtViewTypeAMessage: SZTextView!
    @IBOutlet weak var viewChatContainer: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var constraintViewMessageBottom: NSLayoutConstraint!
    
    // MARK:- View Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addKeyboardNotifications()
        setupUI()
        registerCells()
        setTheDelegates()
        
        // Showing alert for asking user name
        self.showOKWithTxtFldAlert(strMessage: "") { (userName) in
            self.currentUserName = userName
            self.configurePubNub()
            
            self.txtViewTypeAMessage.becomeFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // PubNub
    func configurePubNub() {
        let configuration = PNConfiguration(publishKey: PUBLISH_KEY, subscribeKey: SUBSCRIBE_KEY)
        configuration.stripMobilePayload = false
        
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
        
        // Subscribe to demo channel with presence observation
        self.client.subscribeToChannels([CHANNEL_NAME], withPresence: true)
    }
    
    
    func fetchChatHistory() {
        self.client.historyForChannel(CHANNEL_NAME, withCompletion: { (result, status) in

            if status == nil {

                /**
                 Handle downloaded history using:
                 result.data.start - oldest message time stamp in response
                 result.data.end - newest message time stamp in response
                 result.data.messages - list of messages
                 */

                print("All messeges from channel==>\((result?.data.messages)!)")
                
                var messageArr = result?.data.messages
                messageArr?.reverse()
                
                for index in 0..<(messageArr?.count)! {
                    let messageDict = messageArr?[index] as! [String : String]
                    let messageObj = MessageObj()
                    messageObj.setData(messageString: messageDict[MessageStruct.KEY_MESSAGE_STR] ?? "", senderName: messageDict[MessageStruct.KEY_SENDER_NAME] ?? "", senderUUID: messageDict[MessageStruct.KEY_UUID] ?? "")
                    
                    self.arrFetchedChatMessages.append(messageObj)
                    
                    if index == 4 {
                        break
                    }
                }
               
                self.arrFetchedChatMessages.reverse()
                self.tblViewSingleChat.reloadData()
//                self.tblViewSingleChat.scrollToBottom()
            }
            else {

                /**
                 Handle message history download error. Check 'category' property
                 to find out possible reason because of which request did fail.
                 Review 'errorData' property (which has PNErrorData data type) of status
                 object to get additional information about issue.

                 Request can be resent using: status.retry()
                 */
            }
        })
    }
    
    
    // MARK:- UI Methods
    func setupUI() {
        txtViewTypeAMessage.placeholder = "Type a message..."
        
        viewChatContainer.layer.shadowColor   = UIColor.black.cgColor
        viewChatContainer.layer.shadowOpacity = 0.4
        viewChatContainer.layer.shadowOffset  = CGSize.init(width: -2, height: 0)
        viewChatContainer.layer.shadowRadius  = 3
        
        sendButton.layer.borderColor = UIColor.black.cgColor
        sendButton.layer.borderWidth = 1.0
        
        txtViewTypeAMessage.becomeFirstResponder()
    }
    
    func setTheDelegates() {
        tblViewSingleChat.delegate   = self
        tblViewSingleChat.dataSource = self
    }
    
    func registerCells() {
        tblViewSingleChat.register(UINib(nibName: "ReceiverChatTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiverChatTableViewCell")
        tblViewSingleChat.register(UINib(nibName: "SenderChatTableViewCell", bundle: nil), forCellReuseIdentifier: "SenderChatTableViewCell")

        
        tblViewSingleChat.estimatedRowHeight = 49.0
        tblViewSingleChat.rowHeight = UITableView.automaticDimension
        
        tblViewSingleChat.tableFooterView = UIView()
    }
    
    func addKeyboardNotifications() {
        //Keyboard show/Hide notifications settings
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(SingleChatViewController.keyboardOnScreen(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SingleChatViewController.keyboardOffScreen(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @IBAction func onBtnSend(_ sender: Any) {
        if !Validation.isStringEmpty(txtViewTypeAMessage.text) {
            
            // Select last object from list of channels and send message to it.
            let targetChannel = client.channels().last!
            
            // Preparing dictionary for sending message payload
            let messageDict: [String: String] = [MessageStruct.KEY_MESSAGE_STR : txtViewTypeAMessage.text,
                                               MessageStruct.KEY_SENDER_NAME : currentUserName,
                                               MessageStruct.KEY_UUID : client.currentConfiguration().uuid]
            
            print("messageDict=====>\(messageDict)")
            
            client.publish(messageDict, toChannel: targetChannel,
                           compressed: false, withCompletion: { (publishStatus) -> Void in

                            if !publishStatus.isError {

                                // Message successfully published to specified channel.
                            }
                            else {

                                /**
                                 Handle message publish error. Check 'category' property to find out
                                 possible reason because of which request did fail.
                                 Review 'errorData' property (which has PNErrorData data type) of status
                                 object to get additional information about issue.

                                 Request can be resent using: publishStatus.retry()
                                 */
                            }
            })
            
            txtViewTypeAMessage.text = ""
            
            
        } else {
            self.showOKAlert(strMessage: "Message cannot be empty.")
        }
    }
    
    
    // MARK:- Keyboard Notification Methods -
    @objc func keyboardOnScreen(sender: NSNotification) {
        //Show keyboard and scroll list
        DispatchQueue.main.async {
            if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight    = keyboardRectangle.height
                self.constraintViewMessageBottom.constant = keyboardHeight
            }
            
            UIView.animate(withDuration: 0.30,
                                  delay: 0,
                 usingSpringWithDamping: 500,
                  initialSpringVelocity: 5.0,
                  options: UIView.AnimationOptions.curveLinear,
                             animations: {
                                self.view.layoutIfNeeded()
                            }, completion: { finished in
                                //self.theCurrentManager.scrollToBottom()
                                self.view.layoutIfNeeded()
                            })
        }
    }
    
    @objc func keyboardOffScreen(notification: NSNotification) {
        DispatchQueue.main.async {
            //Hide keyboard and scroll list
            self.constraintViewMessageBottom.constant = 0
            
            UIView.animate(withDuration: 0.30,
                                  delay: 0,
                 usingSpringWithDamping: 0.8,
                  initialSpringVelocity: 0,
                  options: UIView.AnimationOptions.curveEaseInOut,
                             animations: {
                                self.view.layoutIfNeeded()
                            }, completion: { finished in
                                
                            })
        }
    }
    
    
    //MARK: - PNObjectEventListener Methods
    
    // Handle new message from one of channels on which client has been subscribed.
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        // Handle new message stored in message.data.message
        if message.data.channel != message.data.subscription {
            
            // Message has been received on channel group stored in message.data.subscription.
        }
        else {
            
            // Message has been received on channel stored in message.data.channel.
        }
        
        print("Received message: \(String(describing: message.data.message)) on channel \(message.data.channel) " +
            "at \(message.data.timetoken) with UUID \(client.currentConfiguration().uuid)")
        
        // Managing recived message and rendering in UI
        let messageDict = message.data.message as! [String : String]
        let messageObj = MessageObj()
        messageObj.setData(messageString: messageDict[MessageStruct.KEY_MESSAGE_STR] ?? "", senderName: messageDict[MessageStruct.KEY_SENDER_NAME] ?? "", senderUUID: messageDict[MessageStruct.KEY_UUID] ?? "")
        
        self.arrFetchedChatMessages.append(messageObj)
        self.tblViewSingleChat.reloadData()
        self.tblViewSingleChat.scrollToBottom()
        
    }
    
    // New presence event handling.
    func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        
        // Handle presence event event.data.presenceEvent (one of: join, leave, timeout, state-change).
        if event.data.channel != event.data.subscription {
            
            // Presence event has been received on channel group stored in event.data.subscription.
        }
        else {
            
            // Presence event has been received on channel stored in event.data.channel.
        }
        
        if event.data.presenceEvent != "state-change" {
            
            print("\(String(describing: event.data.presence.uuid)) \"\(event.data.presenceEvent)'ed\"\n" +
                "at: \(event.data.presence.timetoken) on \(event.data.channel) " +
                "(Occupancy: \(event.data.presence.occupancy))");
        }
        else {
            
            print("\(String(describing: event.data.presence.uuid)) changed state at: " +
                "\(event.data.presence.timetoken) on \(event.data.channel) to:\n" +
                "\(String(describing: event.data.presence.state))");
        }
    }
    
    // Handle subscription status change.
    func client(_ client: PubNub, didReceive status: PNStatus) {
        
        if status.operation == .subscribeOperation {
            
            // Check whether received information about successful subscription or restore.
            if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
                
                let subscribeStatus: PNSubscribeStatus = status as! PNSubscribeStatus
                if subscribeStatus.category == .PNConnectedCategory {
                    
                    // This is expected for a subscribe, this means there is no error or issue whatsoever.
                    
                    currentUUID = client.currentConfiguration().uuid
                    
                    fetchChatHistory()
                }
                else {
                    
                    /**
                     This usually occurs if subscribe temporarily fails but reconnects. This means there was
                     an error but there is no longer any issue.
                     */
                }
            }
            else if status.category == .PNUnexpectedDisconnectCategory {
                
                /**
                 This is usually an issue with the internet connection, this is an error, handle
                 appropriately retry will be called automatically.
                 */
            }
                // Looks like some kind of issues happened while client tried to subscribe or disconnected from
                // network.
            else {
                
                let errorStatus: PNErrorStatus = status as! PNErrorStatus
                if errorStatus.category == .PNAccessDeniedCategory {
                    
                    /**
                     This means that PAM does allow this client to subscribe to this channel and channel group
                     configuration. This is another explicit error.
                     */
                }
                else {
                    
                    /**
                     More errors can be directly specified by creating explicit cases for other error categories
                     of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,
                     `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
                     or `PNNetworkIssuesCategory`
                     */
                }
            }
        }
    }
}

extension SingleChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFetchedChatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theMessage = arrFetchedChatMessages[indexPath.row]
        
        if theMessage.senderUUID == currentUUID { // Sender cell
            let theCell = tableView.dequeueReusableCell(withIdentifier: "SenderChatTableViewCell") as! SenderChatTableViewCell
            theCell.senderChatMessageLabel.text       = arrFetchedChatMessages[indexPath.row].messageString ?? ""
            
            return theCell
        } else { // Receiver cell
            let theCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverChatTableViewCell") as! ReceiverChatTableViewCell
            theCell.receiverChatMessageLabel.text = arrFetchedChatMessages[indexPath.row].messageString ?? ""
            theCell.receiverNameLabel.text = arrFetchedChatMessages[indexPath.row].senderName ?? ""
            
            return theCell
        }
    }
}

extension SingleChatViewController: UITableViewDelegate {
    
}

extension UITableView {
    func scrollToBottom() {
        let totalSections = self.numberOfSections
        let totalRows = self.numberOfRows(inSection: (totalSections - 1))
        
        let theIndexPath = IndexPath(row: (totalRows - 1), section: (totalSections - 1))
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.scrollToRow(at: theIndexPath, at: .none, animated: true)
        }
    }
}
