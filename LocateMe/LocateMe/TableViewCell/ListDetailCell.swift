//
//  ListDetailCell.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-01.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit

protocol DirectionBtnDelegate: class {
    func didTapDirection(_ tag: Int)
}

class ListDetailCell: UITableViewCell {
    
    var directionDelegate: DirectionBtnDelegate?
    
    @IBOutlet weak var PlaceName: UILabel!
    @IBOutlet weak var PlaceCategory: UILabel!
    @IBOutlet weak var PlaceAddress: UILabel!
    @IBOutlet weak var CallBtn: UIButton!

    @IBOutlet weak var DirectionBtn: UIButton!
    @IBOutlet weak var PlaceIcon: UIImageView!
    @IBOutlet weak var PlaceCate: UILabel!
    

    @IBAction func tappedDirectionBtn(_ sender: UIButton) {
        directionDelegate?.didTapDirection(sender.tag)
    }
    func configure(with name: String, category: String, address: String, phone: String, web: URL?, placeIcon: UIImage, placeColor: UIColor, distance: Double){
        PlaceName.text = name
        PlaceCategory.text = distance.roundToSingleDigit()
        
        PlaceCate.text = category
        PlaceIcon.image = placeIcon
        PlaceIcon.tintColor = placeColor
        
        CallBtn.layer.cornerRadius = CallBtn.frame.width/2
        CallBtn.layer.borderWidth = 1.5
        CallBtn.layer.borderColor = UIColor.teal.cgColor

        DirectionBtn.layer.cornerRadius = CallBtn.frame.width/2
        DirectionBtn.layer.borderWidth = 1.5
        DirectionBtn.layer.borderColor = UIColor.teal.cgColor
    }

}
