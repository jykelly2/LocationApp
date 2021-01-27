//
//  List.swift
//  LocateMe
//
//  Created by Jun K on 2020-12-26.
//  Copyright © 2020 JK. All rights reserved.
//
import UIKit

struct List {
    
    var title: String
    var id: String
    var icon: UIImage
    var color: UIColor
    var placeIds: [Int]
    var count: Int
    
    init(title: String, id: String, icon: UIImage, color: UIColor, placeIds: [Int], count: Int) {
        self.title = title
        self.id = id
        self.icon = icon
        self.color = color
        self.placeIds  = placeIds
        self.count = count
    }
    
}
