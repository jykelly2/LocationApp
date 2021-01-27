//
//  MenuController.swift
//  LocateMe
//
//  Created by Jun K on 2020-12-21.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

enum MenuType: Int {
    case name
    case profile
    case saved
    case notification
    case general
    case logout
}

class MenuController: UITableViewController {
    
    @IBOutlet weak var ProfileImg: UIImageView!
    @IBOutlet weak var ProfileName: UILabel!
    @IBOutlet weak var ProfileEmail: UILabel!
    
    @IBOutlet weak var LoginImg: UIImageView!
    @IBOutlet weak var LoginLbl: UILabel!
   
    
    var didTapMenuType: ((MenuType) -> Void)?
    
    var userId: String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.backgroundColor = .lightTeal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileImg.layer.cornerRadius = ProfileImg.frame.width/2
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
            swipeLeft.direction = .left
        self.tableView.addGestureRecognizer(swipeLeft)
    }

    @objc func handleSwipeLeft(swipeGestureRecognizer: UISwipeGestureRecognizer){
        dismiss(animated: true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuType = MenuType(rawValue: indexPath.row) else { return }
        dismiss(animated: true) { [weak self] in
              self?.didTapMenuType?(menuType)
        }
    }
    
    override func tableView(_ tableView: UITableView,
    heightForRowAt indexPath: IndexPath) -> CGFloat {
        //profile header
        if indexPath.row == 0 {
            return viewAreaWidth/2
        }
        //logout
         if indexPath.row == 1 || indexPath.row == 2 {
            return userId == "" ? 0 : viewAreaWidth/5
        }
        //footer
        if indexPath.row == 6{
            return viewAreaHeight
        }
        return viewAreaWidth/5
    }
}


// MARK: - Menu Functions (Map Controller)

extension MapController {
     @objc func didTapMenu(){
         guard let menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuController") as? MenuController else { return }
        menuViewController.userId = userId
        menuViewController.didTapMenuType = { menuType in
            self.transitionToNew(menuType)
        }
        if userId != ""{
             userDbController.getUser(id: userId){(user) in
                 menuViewController.ProfileName.text = user.username
                 menuViewController.ProfileEmail.text = user.email
                menuViewController.LoginLbl.text = "Log Out"
                menuViewController.LoginImg.image = UIImage(systemName: "escape")?.withTintColor(.teal)
                 if user.imageUrl != ""{
                     let data = NSData(contentsOf: URL(string: user.imageUrl)!)
                     menuViewController.ProfileImg.image = UIImage(data: data! as Data)
                 }
             }
         }
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        present(menuViewController, animated: true)
    }
       
    func transitionToNew(_ menuType: MenuType) {
           let title = String(describing: menuType).capitalized
           self.title = title
            let currentUserId = userDbController.getCurrentUserId()
   
           switch menuType {
           case .profile:
                if currentUserId == ""{
                    pushSignUpController()
                    break
                }
                pushProfileController(currentUserId: currentUserId)
           case .saved:
                if currentUserId == ""{
                    pushSignUpController()
                    break
                }
                pushSavedController(currentUserId: currentUserId)
     
           case .notification:
                 break
           case .general:
                 break
           case .logout:
                if currentUserId == ""{
                    pushSignUpController()
                    break
                }
                logout(currentUserId: currentUserId)
           default:
              break
           }
        
    }

// MARK: - Menu Controller Transition
    
    func pushProfileController(currentUserId: String){
         userDbController.getUser(id: currentUserId) { (user) in
             guard let editProfileController = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileController") as? EditProfileController else { return }
             editProfileController.mediaAccount = AccessToken.current != nil || GIDSignIn.sharedInstance()?.currentUser?.authentication != nil ? true : false
             editProfileController.user = user
                     editProfileController.userId = currentUserId
             self.navigationController?.pushViewController(editProfileController, animated: true)
         }
     }
    
    func pushSavedController(currentUserId: String){
        guard let listController = storyboard?.instantiateViewController(withIdentifier: "SavedController") as? SavedController else { return }
        listController.userId = currentUserId
        self.navigationController?.pushViewController(listController, animated: true)
    }
    
    func pushSignUpController(){
        guard let signUpController = storyboard?.instantiateViewController(withIdentifier: "SignUpController") as? SignUpController else { return }
        self.navigationController?.pushViewController(signUpController, animated: true)
    }
    
    func logout(currentUserId: String){
        if currentUserId != "" {
            userDbController.signOut()
           resetMapView()
         }
        if let _ = GIDSignIn.sharedInstance()?.currentUser?.authentication {
            print("google signing out")
            GIDSignIn.sharedInstance()?.signOut()
         }
         if AccessToken.current != nil {
            print("facebook signing out")
            let fbLoginManager = LoginManager()
            fbLoginManager.logOut()
         }
    }
     
 }


// MARK: - Menu Transition Delegate
extension MapController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transiton.isPresenting = true
        return transiton
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transiton.isPresenting = false
        return transiton
    }
}
