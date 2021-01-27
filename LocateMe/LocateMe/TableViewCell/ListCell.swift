//
//  ListCell.swift
//  LocateMe
//
//  Created by Jun K on 2020-12-25.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit

protocol EditListDelegate: class {
    func didTapEdit(_ tag: Int)
}

protocol CheckBoxDelegate: class {
    func didTapCheckBox(_ sender: CheckBox)
}

class ListCell: UITableViewCell {

    var delegate: EditListDelegate?
    var checkBoxdelegate: CheckBoxDelegate?

    @IBOutlet weak var EditBtn: UIButton!
    @IBOutlet weak var CheckBox: CheckBox!
    
    @IBAction func buttonTapped(_ sender: UIButton) {
           delegate?.didTapEdit(sender.tag)
    }
    @IBOutlet weak var ListIcon: UIImageView!
    
    @IBOutlet weak var ListName: UILabel!
    @IBOutlet weak var ListCount: UILabel!
    
    @IBAction func tappedCheckBox(_ sender: CheckBox) {
        checkBoxdelegate?.didTapCheckBox(sender)
    }
    
    func configure(with listIcon: UIImage, listName: String, listCount: Int, color: UIColor){
        ListIcon.image = listIcon
        ListIcon.tintColor = color
        ListName.text = listName
        ListCount.text = listCount.placeSingularity()
    }
}
