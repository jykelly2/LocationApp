//
//  EditListHeader.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-06.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit
import AnimatedField

class EditListHeader: UICollectionReusableView, AnimatedFieldDataSource {
    
    @IBOutlet weak var ListTxtField: UITextField!
    
    @IBOutlet weak var ListTitleField: AnimatedField!
    
    @IBOutlet weak var ListTitleWidth: NSLayoutConstraint!
    
    func fieldSetup(){
          var titleFontSize: CGFloat = 16.0
          var textFontSize: CGFloat = 18.0
          if traitCollection.userInterfaceIdiom == .pad{
              titleFontSize = 22.0
              textFontSize = 24.0
          }
          var format = AnimatedFieldFormat()
          format.titleFont = UIFont(name: "AvenirNext-Regular", size: titleFontSize)!
          format.textFont = UIFont(name: "AvenirNext-Regular", size: textFontSize)!
          format.alertColor = .red
          format.alertFieldActive = false
          format.titleAlwaysVisible = true
          format.highlightColor = .teal
          format.textColor = .darkGray
          format.alertFont = UIFont(name: "AvenirNext-Regular", size: titleFontSize)!
          
         ListTitleField.format = format
         ListTitleField.placeholder = "List title"
         ListTitleField.dataSource = self
         ListTitleField.lowercased = true
         ListTitleField.type = AnimatedFieldType.none
      }
}

