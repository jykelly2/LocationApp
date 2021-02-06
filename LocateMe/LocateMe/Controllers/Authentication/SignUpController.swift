//
//  LoginController.swift
//  LocateMe
//
//  Created by Jun K on 2020-11-14.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import AnimatedField

@objc(SignUpController)

protocol FacebookDelegate: class {
    @objc func tappedFacebooks(_ sender: UIButton)
}

class SignUpController: AuthenticationBaseController{
    
    @IBOutlet weak var SignUpBtn: UIButton!
    @IBOutlet weak var AppleBtn: UIButton!
    @IBOutlet weak var FacebookBtn: UIButton!
    @IBOutlet weak var GoogleBtn: UIButton!
    @IBOutlet weak var SignInBtn: UIButton!
    
    @IBOutlet weak var BackgroundView: UIView!
    @IBOutlet weak var AppLogoImg: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(animated: animated)
    }
    
    var termsText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    func setUpView(){
        controller = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        SignUpBtn.layer.cornerRadius = 10
        fbLoginBtn.isHidden = true
        fbLoginBtn.delegate = self
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpController.receiveToggleAuthUINotification(_:)), name: NSNotification.Name(rawValue: "ToggleAuthUINotification"), object: nil)
    }
    
    @IBAction func tappedCloseBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedApple(_ sender: UIButton) {
    }
    
    // MARK: - Manual Sign up
    
    @IBAction func tappedSignUp(_ sender: UIButton) {
        tappedSignInOrUp(signUp: true)
    }
    
    func tappedSignInOrUp(signUp: Bool){
        guard let manualSignUpView = storyboard?.instantiateViewController(withIdentifier: "ManualSignUpController") as? ManualSignUpController else { return }
        manualSignUpView.modalPresentationStyle = .overFullScreen
        manualSignUpView.signUp = signUp
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ToggleAuthUINotification"), object: nil)
        self.navigationController?.pushViewController(manualSignUpView, animated: true)
    }
    
    @IBAction func tappedSignIn(_ sender: UIButton) {
        tappedSignInOrUp(signUp: false)
    }
    
    // MARK: - Google Sign up
    
    @IBAction func tappedGoogle(_ sender: UIButton) {
        tappedGoogles()
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ToggleAuthUINotification"), object: nil)
    }
    
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        googleSignIn(notification: notification)
    }
    
    // MARK: - Facebook sign up
    
    @IBAction func tappedFacebook(_ sender: UIButton) {
        fbLoginBtn.sendActions(for: .touchUpInside)
    }
}

extension SignUpController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        getUserDataFromFacebook()
    }
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("user logged out")
    }
}



