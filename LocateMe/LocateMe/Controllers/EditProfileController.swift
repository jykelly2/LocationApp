//
//  EditProfileController.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-25.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit
import AnimatedField

class EditProfileController: UIViewController {
    
    @IBOutlet weak var UsernameField: AnimatedField!
    @IBOutlet weak var EmailField: AnimatedField!
    @IBOutlet weak var SubmitBtn: UIButton!
    
    let userDbController = UserDbController()
    
    var mediaAccount = false
    var user: User?
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    
        SubmitBtn.layer.cornerRadius = 10
        setDefaultTitleNavigationBar(navTitle: "Edit Profile", backText: "")
        showNavigationBar(animated: true)
        
        fieldSetup()
    }
    
    func fieldSetup(){
         var format = AnimatedFieldFormat()
         format.titleFont = UIFont(name: "AvenirNext-Regular", size: 16)!
         format.textFont = UIFont(name: "AvenirNext-Regular", size: 18)!
         format.alertColor = .red
         format.alertFieldActive = false
         format.titleAlwaysVisible = true
        format.highlightColor = .teal
        format.textColor = .darkGray
         format.alertFont = UIFont(name: "AvenirNext-Regular", size: 16)!
    
         EmailField.format = format
         EmailField.placeholder = "Email"
         EmailField.dataSource = self
         EmailField.delegate = self
         EmailField.type = .email
         EmailField.text = user?.email
           
         UsernameField.format = format
         UsernameField.placeholder = "Username"
         UsernameField.dataSource = self
         UsernameField.delegate = self
         UsernameField.lowercased = true

        UsernameField.type =  AnimatedFieldType.none
         UsernameField.text = user?.username
     
         EmailField.isUserInteractionEnabled = !mediaAccount
   }
    
      
// MARK: - Button Action
    @IBAction func tappedSubmitBtn(_ sender: UIButton) {
          if checkIfValid(){
              if mediaAccount{
                  if let id = userId, let username = UsernameField.text{
                      userDbController.updateUsername(userId: id, username: username)
                  }
              }else{
                  if let password = user?.password, let imageUrl = user?.imageUrl, let id = userId, let user = User(username: UsernameField.text!, email: EmailField.text!, password: password , imageUrl: imageUrl){
                      userDbController.updateUser(userId: id, user: user)
                  }
              }
              self.navigationController?.popViewController(animated: true)
          }
      }
      
   func checkIfValid() -> Bool{
        var validated = false
        if EmailField.text != "" && UsernameField.text?.count ?? 0 >= 3 {
                validated = EmailField.isValid
        }
        return validated
    }
}
  
// MARK: - Animated Field Functions

extension EditProfileController: AnimatedFieldDelegate {
    func animatedFieldDidEndEditing(_ animatedField: AnimatedField) {
        if animatedField == UsernameField {
            if UsernameField.text?.count ?? 0 < 3 {
                UsernameField.showAlert("Need at least 3 characters")
            }
        }
    }

}

extension EditProfileController: AnimatedFieldDataSource {
    func animatedFieldValidationError(_ animatedField: AnimatedField) -> String? {
        return "Need to be in email format"
    }
}
