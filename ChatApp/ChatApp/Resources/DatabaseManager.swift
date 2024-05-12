//
//  DatabaseManager.swift
//  ChatApp
//
//  Created by Anurag Bhatt on 12/05/24.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager
{
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
}

// MARK:- ACCOUNT MANAGEMENT

extension DatabaseManager{
    
    public func userExists(with email : String ,
                           completion : @escaping ((Bool) -> Void)){
        
        database.child(email).observeSingleEvent(of: .value, with: {snapshot in
            
            guard snapshot.value as? String != nil else{
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    /// inserts new user to database
    public func insertUser(with user : ChatAppUser){
        database.child(user.emailAddress).setValue([
            "first_name" : user.firstName,
            "last_name" : user.lastName
        ])
    }
}

struct ChatAppUser{
    let firstName : String
    let lastName : String
    let emailAddress : String
//    let profilePictureUrl : String
}
