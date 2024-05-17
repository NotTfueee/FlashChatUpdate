//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Anurag Bhatt on 18/05/24.
//

import Foundation


enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
