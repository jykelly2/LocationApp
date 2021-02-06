//
//  UserDbController.swift
//  LocateMe
//
//  Created by Jun K on 2020-12-23.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


public class UserDbController{
    
    let group = DispatchGroup()
    var db : Firestore!
    
    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    func addNewUser(newUser: User, completion:@escaping (String) -> Void){
        guard let user = newUser as User? else {return}
        var newId = ""
        
        //add user to firebase
        Auth.auth().createUser(withEmail: user.email, password: user.password){ authResult, error in
            if let err = error{
                print("Error adding user: \(err)")
            }else{
                newId = authResult!.user.uid
                print(newId)
                DispatchQueue.main.async {
                    self.db.collection("users").document(newId).setData([
                        "username" : user.username,
                        "email" : user.email,
                        "password" : user.password,
                        "imageUrl" : user.imageUrl
                    ]){ err in
                        if let err = err{
                            print("Error adding user: \(err)")
                        }else{
                            completion(newId)
                            print("user added with Id: \(newId)")
                        }
                    }
                }
            }
        }
    }
    
    func updateUsername(userId:String, username: String){
        let ref = self.db.collection("users").document(userId)
        ref.updateData([
            "username": username
        ]){ err in
            if let err = err{
                print("Error updating user: \(err)")
            }else{
                print("updated user with Id: \(ref.documentID)")
            }
        }
    }
    
    func updateUser(userId: String, user: User){
        if let oldUser = Auth.auth().currentUser{
            oldUser.updateEmail(to: user.email) { error in
                if let err = error {
                    print("Error updating user: \(err)")
                } else {
                    self.db.collection("users").document(userId).setData([
                        "username" : user.username,
                        "email" : user.email,
                        "password" : user.password,
                        "imageUrl" : user.imageUrl
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
            }
        }  
    }
    
    func getUser(id:String, completion: @escaping (User) -> Void){
        var user : User?
        db.collection("users").document(id).getDocument{ (document,err) in
            if let document = document, document.exists{
                let docData = document.data()!
                user = User(username: docData["username"] as! String,
                            email: docData["email"] as! String,
                            password: docData["password"] as! String, imageUrl: docData["imageUrl"] as! String)
                completion(user!)
            }else{
                print("document does not exist")
                user = nil
            }
        }
    }
    
    func checkIfUserExist(email: String, completion: @escaping (Bool) -> Void){
        var userExist = false
        let docRef = db.collection("users").whereField("email", isEqualTo: email).limit(to: 1)
        docRef.getDocuments { (querysnapshot, error) in
            if error != nil {
                print("Document Error: ", error!)
            } else {
                if let doc = querysnapshot?.documents, !doc.isEmpty {
                    userExist = true
                    print("User already exists")
                }
                completion(userExist)
            }
        }
    }
    
    func getCurrentUserId() -> String{
        let id = Auth.auth().currentUser?.uid != nil ? Auth.auth().currentUser!.uid : ""
        return id
    }
    
    func signIn(existingUser: User, completion: @escaping (String) -> Void){
        guard let user = existingUser as User? else {return}
        Auth.auth().signIn(withEmail: user.email, password: user.password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let err = error{
                print("Error signing in user: \(err)")
            }else{
                let id = authResult?.user.uid != nil ? authResult!.user.uid : ""
                completion(id)
            }
        }
    }
    func signOut(){
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}


