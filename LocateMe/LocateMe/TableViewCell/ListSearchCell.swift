//
//  ListSearchCell.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-26.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit

class ListSearchCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    func configure(list:List){
       iconImageView.image = list.icon
       iconImageView.tintColor = list.color
       titleLabel.text = list.title
       subTitleLabel.text = list.placeIds.count.placeSingularity()
    }
}
