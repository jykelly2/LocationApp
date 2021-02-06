//
//  Enums.swift
//  LocateMe
//
//  Created by Jun K on 2021-02-01.
//  Copyright © 2021 JK. All rights reserved.
//


enum traceState {
    case start
    case stop
    case restart
    case neutral
}

enum FpcType{
    case search
    case list
    case place
}

enum MenuType: Int {
    case name
    case profile
    case saved
    case notification
    case general
    case logout
}
