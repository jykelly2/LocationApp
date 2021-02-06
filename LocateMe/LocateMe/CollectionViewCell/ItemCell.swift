//
//  ItemCell.swift
//  LocateMe
//
//  Created by Jun K on 2020-12-24.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    
    //var addLocationDelegate: AddLocationDelegate?
    @IBOutlet weak var BackView: UIView!
    
    @IBOutlet weak var ListName: UILabel!
    @IBOutlet weak var ListIcon: UIImageView!
    @IBOutlet weak var CategoryLabel: UILabel!
    @IBOutlet weak var ItemIcon: UIImageView!
    @IBOutlet weak var ItemLabel: UILabel!
    @IBOutlet weak var ItemIconTop: NSLayoutConstraint!
    @IBOutlet weak var ItemLabelTop: NSLayoutConstraint!
    @IBOutlet weak var ItemIconHeight: NSLayoutConstraint!
    @IBOutlet weak var ItemIconWidth: NSLayoutConstraint!
    
    func configure(with itemLabel: String, itemImg: UIImage, categoryLabel: String, listImg: UIImage, listLabel: String, color: UIColor){
        ItemLabel.text = itemLabel
        CategoryLabel.text = categoryLabel
        ListName.text = listLabel
        BackView.backgroundColor = color
        
        ItemIcon.setUpIconImg(img: itemImg, color: color, inset: 30)
        ItemIcon.tintColor = UIColor.white
        
        ItemIcon.layer.borderWidth = 2
        ItemIcon.layer.borderColor = UIColor.white.cgColor
        //ItemIcon.layer.cornerRadius = ItemIcon.frame.size.width / 2
        
        let listIcon = self.setListIcon(title: listLabel)
        ListIcon.image = listIcon.0
        ListIcon.tintColor = listIcon.1
        
        BackView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: ItemIcon.frame.midY)
    }
    func emptyConfigure(){
        
        ItemLabel.text = "Add new \nlocation"
        ItemLabel.textColor = .systemGray
        CategoryLabel.text = ""
        ListName.text = ""
        ItemIcon.image = UIImage(named: "plusicon")?.withRenderingMode(.alwaysTemplate)
        ItemIcon.tintColor = UIColor.link
        
        let contentHeight = self.contentView.frame.height
        ItemIcon.translatesAutoresizingMaskIntoConstraints = false
        ItemIcon.isUserInteractionEnabled = true
        ItemIconTop.constant = 40        
        ItemIcon.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ItemIconHeight.constant = 45
        //ItemIconWidth.constant = 45
        
        ItemIcon.addGestureRecognizer(UITapGestureRecognizer(target: self.ItemIcon, action: #selector(SavedController.tappedAddNew(_:))))
        
        ItemLabel.translatesAutoresizingMaskIntoConstraints = false
        ItemLabelTop.constant = 10
        ItemLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ItemLabel.numberOfLines = 0
        ItemLabel.font = UIFont(name: "HelveticaNeue-Medium", size: contentHeight/10)
        
    }
}
