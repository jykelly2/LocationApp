//
//  AuthenticationBaseController.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-24.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class AuthenticationBaseController: UIViewController{
    
    let isPhone = UIDevice.isPhone
    let userDbController = UserDbController()
    var controller = UIViewController()
    var manual: Bool = false
    let fbLoginBtn = FBLoginButton(frame: .zero, permissions: [.publicProfile, .email])
    
    
    // MARK: - Google Sign In
    
    func tappedGoogles() {
        if let _ = GIDSignIn.sharedInstance()?.currentUser?.authentication {
            GIDSignIn.sharedInstance()?.signOut()
        }else{
            GIDSignIn.sharedInstance()?.signIn()
        }
    }
    
    func googleSignIn(notification: NSNotification){
        if notification.name.rawValue == "ToggleAuthUINotification" {
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:String] else { return }
                if let username = userInfo["fullName"],let email = userInfo["email"], let imageUrl = userInfo["imageUrl"], let user = User(username: username, email: email, password: "defaultPassword", imageUrl: imageUrl){
                    if !manual{
                        self.signUp(user: user)
                    }else{
                        self.login(user: user)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Facebook Sign In
    func getUserDataFromFacebook() {
        GraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, email, picture, id"]).start { (connection, result, error) in
            if let err = error { print(err.localizedDescription); return } else {
                if let fields = result as? [String:Any], let firstName = fields["first_name"] as? String, let lastName = fields["last_name"] as? String, let email = fields["email"] as? String, let imageURL = ((fields["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String{
                    
                    if let user = User(username: "\(firstName) \(lastName)" , email: email, password: "defaultPassword", imageUrl: imageURL){
                        if !self.manual{
                            self.signUp(user: user)
                        }else{
                            self.login(user: user)
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                                  object: nil)
    }
    
    
    // MARK: - Sign up functions
    func signUp(user: User){
        self.userDbController.checkIfUserExist(email: user.email){ (duplicate) in
            if !duplicate {
                self.userDbController.addNewUser(newUser: user){ (id) in
                    if id != ""{
                        self.login(user: user)
                    }
                }
            }else{
                self.userDbController.signIn(existingUser: user) { (id) in
                    self.transitionToController(id: id)
                }
            }
        }
    }
    
    func login(user: User){
        userDbController.signIn(existingUser: user){userId in
            if userId != "" {
                self.transitionToController(id: userId)
            }
        }
    }
    
    func transitionToController(id: String){
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                                  object: nil)
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let savedController = storyBoard.instantiateViewController(withIdentifier: "SavedController") as? SavedController else {return}
        savedController.fromSignUp = true
        savedController.userId = id
        controller.navigationController?.pushViewController(savedController, animated: true)
    }
    
}
