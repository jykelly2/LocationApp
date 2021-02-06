//
//  PlaceDetailCell.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-02.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit

class PlaceDetailCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var information: UILabel!
    
    func configure(with sectionTitle: String, sectionInfo: String, section: Int){
        information.text = sectionInfo
        title.text = sectionTitle
        
        switch section {
        case 1,2:
            information.textColor = .link
        default:
            print("address")
        }
    }
    
}
