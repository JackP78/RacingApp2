//
//  ChatViewController.swift
//  ListowelSwift
//
//  Created by Jack McAuliffe on 17/02/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

import UIKit
import FirebaseDatabase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    // MARK: Properties
    var messages = [JSQMessage]()
    let rootRef = Database.database().reference()
    var messageRef: DatabaseReference!
    var usersTypingQuery: DatabaseQuery!
    var objectContext = ObjectContext()
    fileprivate let imagePicker = UIImagePickerController()
    
    var userIsTypingRef: DatabaseReference! // 1
    fileprivate var localTyping = false // 2
    // Note: jack this is a property
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    fileprivate func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
        messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
            return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return messages.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        objectContext.ensureLoggedInWithCompletion(self) { (user) in
            self.senderId = user.uid // 3
            self.senderDisplayName = user.displayName
        }
        
        // Do any additional setup after loading the view.
        title = "ChatChat"
        setupBubbles()
        messageRef = rootRef.child("messages")
        
        // Put back avatars when done
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        observeMessages()
        observeTyping()
        
        imagePicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
        messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
            let message = messages[indexPath.item] // 1
            if message.senderId == senderId { // 2
                return outgoingBubbleImageView
            } else { // 3
                return incomingBubbleImageView
            }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
                as! JSQMessagesCollectionViewCell
            
            let message = messages[(indexPath as NSIndexPath).item]
            
            if message.senderId == senderId {
                cell.textView!.textColor = UIColor.white
            } else {
                cell.textView!.textColor = UIColor.black
            }
            
            return cell
    }
    
    fileprivate func observeMessages() {
        // 1
        let messagesQuery = messageRef.queryLimited(toLast: 25)
        // 2
        messagesQuery.observe(.childAdded) { (snapshot: DataSnapshot!) in
            NSLog("\(snapshot)")
            NSLog("\(snapshot.value)")
            // 3
            let id = (snapshot.value! as AnyObject).object(forKey: "senderId") as! String
            let text = (snapshot.value! as AnyObject).object(forKey: "text") as! String
            self.addMessage(id, text: text)
            
            // 5
            self.finishReceivingMessage()
        }
    }
    
    func addMessage(_ id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message!)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!,
        senderDisplayName: String!, date: Date!) {
            
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem:[String:AnyObject] = [ // 2
            "text": text! as AnyObject,
            "senderId": senderId! as AnyObject,
        ]
        itemRef.setValue(messageItem) // 3
            
            // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
            
            // 5
        finishSendingMessage()
        isTyping = false
        
        if self.inputToolbar.contentView.textView.isFirstResponder {
            self.inputToolbar.contentView.textView.resignFirstResponder()
        }
    }
    
    fileprivate func observeTyping() {
        let typingIndicatorRef = rootRef.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        // 1
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
        
        // 2
        usersTypingQuery.observe(.value) { (data: DataSnapshot!) in
            
            // 3 You're the only typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // 4 Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    
    
    // called when the image is picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String :
        Any])
    {
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let mediaItem = JSQPhotoMediaItem(image: nil)
            mediaItem?.appliesMediaViewMaskAsOutgoing = true
            mediaItem?.image = UIImage(data: UIImageJPEGRepresentation(picture, 0.5)!)
            if let sendMessage = JSQMessage(senderId: senderId, displayName: "Jack", media: mediaItem) {
                self.messages.append(sendMessage)
            }
            self.finishSendingMessage()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}
