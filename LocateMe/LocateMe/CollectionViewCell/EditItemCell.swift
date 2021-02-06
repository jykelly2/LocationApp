//
//  EditItemCell.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-06.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit

class EditItemCell: UICollectionViewCell {
    
    @IBOutlet weak var PlaceName: UILabel!
    @IBOutlet weak var PlaceCategory: UILabel!
    @IBOutlet weak var DeleteBtn: UIButton!
    @IBOutlet weak var PlaceAddress: UILabel!
    @IBOutlet weak var PlaceIcon: UIImageView!
    
    let listTextField: UITextField = {
        let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.textColor = UIColor.lightGray
        text.backgroundColor = .white
        text.layer.borderColor = UIColor.lightGrey.cgColor
        text.textAlignment = .left
        return text
    }()
    
    func configure(with placeName: String, placeCategory: String, placeAddress: String, iconImg: UIImage, color: UIColor){
        PlaceName.text = placeName
        PlaceCategory.text = placeAddress//placeCategory
        PlaceAddress.text = placeCategory //placeAddress
        PlaceIcon.image = iconImg
        PlaceIcon.tintColor = color
    }
    
    func titleConfigure(with listName: String){
        PlaceCategory.isHidden = true
        PlaceAddress.isHidden = true
        DeleteBtn.isHidden = true
        
        PlaceName.text = "List name:"
        listTextField.text = listName
        listTextField.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        contentView.addSubview(listTextField)
        
        listTextField.topAnchor.constraint(equalTo: PlaceName.bottomAnchor, constant: 3).isActive = true
        listTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        listTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        listTextField.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.3).isActive = true
        
        
        
    }
    
    
    
    
}
