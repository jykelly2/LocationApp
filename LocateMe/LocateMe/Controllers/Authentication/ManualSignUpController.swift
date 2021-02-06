//
//  ManualSignUpController.swift
//  LocateMe
//
//  Created by Jun K on 2020-11-23.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import FirebaseAuth
import AnimatedField

@objc(ManualSignUpController)

class ManualSignUpController: AuthenticationBaseController {
    
    @IBOutlet weak var UsernameField: AnimatedField!
    @IBOutlet weak var EmailField: AnimatedField!
    @IBOutlet weak var PasswordField: AnimatedField!
    
    @IBOutlet weak var SubmitBtn: UIButton!
    
    @IBOutlet weak var MediaStack: UIStackView!
    @IBOutlet weak var AgreementLbl: UILabel!
    @IBOutlet weak var SignInLbl: UILabel!
    
    @IBOutlet weak var AppleBtn: UIButton!
    @IBOutlet weak var FacebookBtn: UIButton!
    @IBOutlet weak var GoogleBtn: UIButton!
    
    var signUp: Bool = true
    var valid = false
    
    
    @IBAction func tappedAppleBtn(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        fieldSetup()
    }
    
    func setUpView(){
        hideKeyboardWhenTappedAround()
        manual = true
        controller = self
        var title = ""
        
        if !signUp {
            UsernameField.isHidden = true
            title = "Log in"
            SubmitBtn.setTitle("SIGN IN", for: .normal)
            fbLoginBtn.isHidden = true
            fbLoginBtn.delegate = self
            
            GIDSignIn.sharedInstance()?.presentingViewController = self
            
            NotificationCenter.default.addObserver(self, selector: #selector(ManualSignUpController.receiveToggleAuthUINotification(_:)),
                                                   name: NSNotification.Name(rawValue: "ToggleAuthUINotification"), object: nil)
        }else{
            SignInLbl.isHidden = true
            MediaStack.isHidden = true
            title = "Sign up"
        }
        
        SubmitBtn.layer.cornerRadius = 10
        
        self.setDefaultTitleNavigationBar(navTitle: title, backText: "")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
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
        
        format.visibleOnImage = UIImage(systemName: "eye.slash")!
        format.visibleOffImage = UIImage(systemName: "eye.fill")!
        
        EmailField.format = format
        EmailField.placeholder = "Email"
        EmailField.dataSource = self
        EmailField.delegate = self
        EmailField.type = .email
        
        UsernameField.format = format
        UsernameField.placeholder = "Username"
        UsernameField.dataSource = self
        UsernameField.delegate = self
        UsernameField.lowercased = true
        UsernameField.type = AnimatedFieldType.none
        
        PasswordField.format = format
        PasswordField.placeholder = "Password"
        PasswordField.dataSource = self
        PasswordField.delegate = self
        PasswordField.type = .password(6, 20)
        PasswordField.isSecure = true
        PasswordField.showVisibleButton = true
    }
    
    // MARK: - Manual Sign up/Sign In
    @IBAction func tappedSubmit(_ sender: UIButton) {
        if checkIfValid(){
            if signUp{
                if let user = User(username: UsernameField.text!, email: EmailField.text!, password: PasswordField.text!, imageUrl: ""){
                    self.signUp(user: user)
                }
            }else{
                if let user = User(username: "", email: EmailField.text!, password: PasswordField.text!, imageUrl: ""){
                    login(user: user)
                }
            }
        }
    }
    
    func checkIfValid() -> Bool{
        var validated = false
        if signUp {
            if EmailField.text != "" && PasswordField.text != "" && UsernameField.text?.count ?? 0 >= 3 {
                validated = EmailField.isValid && PasswordField.isValid
            }
        }else{
            if  EmailField.text != "" && PasswordField.text != ""{
                validated = EmailField.isValid && PasswordField.isValid
            }
        }
        return validated
    }
    
    
    // MARK: - Google Sign In
    
    @IBAction func tappedGoogleBtn(_ sender: UIButton) {
        tappedGoogles()
    }
    
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        googleSignIn(notification: notification)
    }
    
    // MARK: - Facebook Sign In
    
    @IBAction func tappedFacebookBtn(_ sender: UIButton) {
        fbLoginBtn.sendActions(for: .touchUpInside)
    }
    
}

extension ManualSignUpController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        getUserDataFromFacebook()
    }
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("user logged out")
    }
}


// MARK: - Animated Field Function

extension ManualSignUpController: AnimatedFieldDelegate {
    func animatedFieldDidEndEditing(_ animatedField: AnimatedField) {
        if animatedField == UsernameField {
            if UsernameField.text?.count ?? 0 < 3 {
                UsernameField.showAlert("Need at least 3 characters")
            }
        }
    }
}

extension ManualSignUpController: AnimatedFieldDataSource {
    func animatedFieldValidationError(_ animatedField: AnimatedField) -> String? {
        switch animatedField {
        case EmailField :
            return "Need to be in email format"
        default:
            return "Need at least 6 characters"
        }
    }
}











