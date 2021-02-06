//
//  SectionHeaderCell.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-10.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit

class SectionHeaderCell: UITableViewCell {
    
    @IBOutlet weak var SectionTitle: UILabel!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
}
