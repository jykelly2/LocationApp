//
//  User.swift
//  LocateMe
//
//  Created by Jun K on 2020-12-23.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation
struct User{
    
    let username : String
    let email : String
    let password : String
    let imageUrl: String
    
    init?(username: String, email: String, password: String, imageUrl: String){
        self.username = username
        self.email = email
        self.password = password
        self.imageUrl = imageUrl
    }
}
