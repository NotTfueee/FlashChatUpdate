//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Anurag Bhatt on 14/05/24.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message : MessageType {
    
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    
    var messageKindString : String {
        switch self{
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}
struct Sender : SenderType {
    public var photoURL : String
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        return formattre
    }()
    
    public let otherUserEmail : String
    private let conversationId : String?
    public var isNewConversation = false
    
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)

        return Sender(photoURL: "",
                      senderId: safeEmail,
                      displayName: "Me")
    }
    

    
    
    init(with email : String , id: String? )
    {
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        
       
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
       
        
    }
    
    private func listenForMessages(id : String , shouldScrollToBottom: Bool){
        
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            
            switch result {
                
            case .success(let messages):
                
                print("success in getting messages \(messages)")
                guard !messages.isEmpty else {
                    
                    print("Messages are empty")
                    return
                }
                
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
                
            case .failure(let error):
                print("Failed to get messages : \(error)")
            }
        })
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        
        if let conversationId = conversationId{
            
            listenForMessages(id: conversationId , shouldScrollToBottom : true)
        }
    }
}

extension ChatViewController : InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty ,
              let selfSender = self.selfSender ,
              let messageId = createMessageId() else{
            return
        }
        
        print("\(text)")
        // send message
        
        let mmessage = Message(sender: selfSender,
                               messageId: messageId,
                               sentDate: Date(),
                               kind: .text(text))
        
        if isNewConversation{
            // create convon in database
            
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail,
                                                         name : self.title ?? "User",
                                                         firstMessage: mmessage,
                                                         completion: { [weak self]success in
                
                if success{
                    print("message sent")
                    
                    self?.isNewConversation = false
                }
                else {
                    print("failed to send ")
                }
            })
        }
        else
        {
            
            guard let conversationId = conversationId , let name = self.title else {
                return
            }
            
            //append to existing conversation data
            
            DatabaseManager.shared.sendMessage(to: conversationId , otherUserEmail: otherUserEmail, name : name, newMessage: mmessage , completion: {success in
                
                if success {
//                    self?.messageInputBar.inputTextView.text = nil
                    print("message sent")
                }
                else {
                    print("failed to send")
                }
            })
            
            print("checking")
        }
    }
    
    private func createMessageId() -> String? {
        
        // date , otherUserEmail , senderEmail  , randomInt
        
        
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        print("created message id \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController : MessagesDataSource , MessagesLayoutDelegate , MessagesDisplayDelegate {
    
    func currentSender() -> any SenderType {
        
        if let sender = selfSender{
            return sender
        }
        
        fatalError("Self Sender is Nil , email should be cached")

    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> any MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
