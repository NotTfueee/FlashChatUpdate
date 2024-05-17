//
//  ConversationsModel.swift
//  ChatApp
//
//  Created by Anurag Bhatt on 18/05/24.
//

import Foundation


struct Conversation{
    let id : String
    let name : String
    let otherUserEmail : String
    let latestMessage : LatestMessage
}

struct LatestMessage {
    let date : String
    let text : String
    let isRead : Bool
}
