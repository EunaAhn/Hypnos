//
//  User.swift
//  Hypnos02
//
//  Created by Euna Ahn on 2023/07/22.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let modelnumber: String
    let email: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: modelnumber){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
}

extension User{
    static var MOCK_USER = User(id: NSUUID().uuidString, modelnumber: "Kobe Bryant", email: "test@gmail.com")
}
