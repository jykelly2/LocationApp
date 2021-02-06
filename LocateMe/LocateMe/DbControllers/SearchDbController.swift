//
//  SearchDbController.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-10.
//  Copyright © 2021 JK. All rights reserved.
//

import Firebase
import FirebaseCore
import FirebaseFirestore
import MapKit


public class SearchDbController{
    
    let group = DispatchGroup()
    var db : Firestore!
    
    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    func addSearch(userId:String, searchTitle: String, id: Int){
        var ref : DocumentReference? = nil
        ref = self.db.collection("users").document(userId) .collection("search").addDocument(data: [
            "title" : searchTitle,
            "id" : id,
        ]){ err in
            if let err = err{
                print("Error adding list: \(err)")
            }else{
                guard let documentId = ref?.documentID else {return}
                print("search added with Id: \(documentId)")
            }
        }
    }
    
    func getAllSearches(userId:String, completion: @escaping ([Search]) -> Void){
        var searches = [Search]()
        db.collection("users").document(userId).collection("search").order(by: "id", descending: true).limit(to: 3).getDocuments(){ (QuerySnapshot,err) in
            if let err = err{
                print("error getting users: \(err)")
                searches = []
            }else{
                for doc in QuerySnapshot!.documents{
                    if let title = doc.data()["title"] as? String, let id = doc.data()["id"] as? Int{
                        let search = Search(title: title , id: id)
                        searches.append(search)
                    }
                }
            }
            completion(searches)
        }
    }
    
}



