//
//  SettingCell.swift
//  LocateMe
//
//  Created by Jun K on 2020-11-13.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {

    let isPhone = UIDevice.isPhone
       
      let label: UILabel = {
              let label = UILabel()
              label.translatesAutoresizingMaskIntoConstraints = false
              label.textAlignment = .left
              label.minimumScaleFactor = 0.1
              label.adjustsFontSizeToFitWidth = true
              label.numberOfLines = 1
               label.textColor = .lightGray
           return label
       }()
   let img: UIImageView = {
                let img = UIImageView()
                img.translatesAutoresizingMaskIntoConstraints = false
                img.contentMode = .scaleAspectFit
                return img
      }()
    
    func setUpSetting(title:String, image: UIImage){
        
        label.text = title
        img.image = image
        img.tintColor = .darkerGray
        if title == "Log Out"{
            label.textColor = .lightRed
        }
        contentView.addSubview(img)
        contentView.addSubview(label)
        
        img.heightAnchor.constraint(equalTo: contentView.widthAnchor,  multiplier:0.08).isActive=true
        img.widthAnchor.constraint(equalTo: contentView.widthAnchor,  multiplier:0.08).isActive=true
        img.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        img.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: safeAreaLayoutGuide.layoutFrame.width/20).isActive = true
        
        label.leadingAnchor.constraint(equalTo: img.trailingAnchor, constant: safeAreaLayoutGuide.layoutFrame.width/20).isActive = true
       label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

}
