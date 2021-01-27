//
//  PreferenceDbController.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-20.
//  Copyright © 2021 JK. All rights reserved.
//

import Firebase
import FirebaseCore
import FirebaseFirestore


public class PreferenceDbController{
    
    var db : Firestore!
    
    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    
    func setDistance(distance: Double){
        db.collection("users").document("preference").setData([
            "distance": distance,
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    

}
