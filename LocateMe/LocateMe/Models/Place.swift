//
//  Place.swift
//  LocateMe
//
//  Created by Jun K on 2020-10-22.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation
import MapKit

class Place {
    
    var name: String
    var address: String
    var phone: String
    var website: URL?
    var category: String
    var coordinate: CLLocationCoordinate2D
    var time: String
    var distance: Double
    var id: Int
    var dbId : String
    var list : [String]
    var icon : UIImage
    var color: UIColor
        
    init(name: String, address: String , phone: String, website: URL, category: String, coordinate: CLLocationCoordinate2D, time: String, distance: Double, id: Int, dbId: String, list: [String], icon: UIImage, color: UIColor){
                    self.name = name
                    self.address = address
                    self.phone = phone
                    self.website = website
                    self.category = category
                    self.coordinate = coordinate
                    self.time = time
                    self.distance = distance
                    self.id = id
                    self.dbId = dbId
                    self.list = list
                    self.icon = icon
                    self.color = color
    }
    
    convenience init(name: String, address: String , phone: String, website: URL, category: String, coordinate: CLLocationCoordinate2D, time: String, distance: Double, dbId: String) {
        self.init(name: name, address: address, phone: phone, website: website, category: category, coordinate: coordinate, time: time, distance: distance, id: 0, dbId: dbId , list: [], icon: UIImage(named:"callicon")!, color: UIColor.lightRed)
    }
    
    convenience init(name: String, address: String , phone: String, website: URL, category: String, coordinate: CLLocationCoordinate2D, id: Int, dbId: String, list: [String], icon: UIImage, color: UIColor) {
        self.init(name: name, address: address, phone: phone, website: website, category: category, coordinate: coordinate, time: "0", distance: 0, id: id, dbId: dbId, list: list, icon: icon, color: color)
    }
    
    convenience init(name: String, address: String , phone: String, website: URL, category: String, coordinate: CLLocationCoordinate2D, distance: Double, icon: UIImage, color: UIColor) {
        self.init(name: name, address: address, phone: phone, website: website, category: category, coordinate: coordinate, time: "0", distance: distance, id: 0, dbId: "", list: [], icon: icon, color: color)
    }
}
