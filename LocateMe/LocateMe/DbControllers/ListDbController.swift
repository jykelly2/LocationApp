//
//  ListDbController.swift
//  LocateMe
//
//  Created by Jun K on 2020-12-23.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore

public class ListDbController{
    
    let group = DispatchGroup()
    var db : Firestore!
    let placeDbController = PlaceDbController()
    
    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }

    func addNewList(title: String, userId:String, completion:@escaping (String) -> Void){
           var ref : DocumentReference? = nil
           ref = self.db.collection("users").document(userId) .collection("lists").addDocument(data: [
               "title" : title,
               "places" : [Int](),
           ]){ err in
               if let err = err{
                   print("Error adding list: \(err)")
               }else{
                guard let documentId = ref?.documentID else {return}
                completion(documentId)
                   print("list added with Id: \(documentId)")
               }
           }
    }
    
    func addDefaultLists(userId:String, completion:@escaping ([List]) -> Void){
        let defaultTitle = ["Favourite", "To explore", "Recreational", "Starred"]
        let defaultImgs = [UIImage(systemName: "heart"),UIImage(systemName: "flag"), UIImage(systemName: "music.house"), UIImage(systemName: "star")]
        let defaultColor = [UIColor.lightRed, UIColor.lightGreen, UIColor.lightTeal, UIColor.lightOrange]
        
        var lists = [List]()
        
        for i in 0...3{
             var ref : DocumentReference? = nil
             ref = self.db.collection("users").document(userId) .collection("lists").addDocument(data: [
                 "title" : defaultTitle[i],
                 "places" : [Int](),
             ]){ err in
                 if let err = err{
                     print("Error adding list: \(err)")
                 }else{
                  guard let documentId = ref?.documentID else {return}
                    let list = List(title: defaultTitle[i], id: documentId, icon: defaultImgs[i] ?? UIImage(named: "locationicon")!, color: defaultColor[i], placeIds: [], count: 0)
                    lists.append(list)
                     print("list added with Id: \(documentId)")
                 }
                if i == 3{
                    completion(lists)
                }
            }
        }
    }
    
    func addNewPlaceToList(place: Place, userId:String, listId: String, placeId: Int){
          let ref = self.db.collection("users").document(userId) .collection("lists").document(listId)
           ref.updateData([
               "places": FieldValue.arrayUnion([placeId])
           ]){ err in
               if let err = err{
                   print("Error updating list: \(err)")
               }else{
                   print("updated list with Id: \(ref.documentID)")
               }
           }
    }
    
    func updateListTitle(userId:String, listId: String, oldTitle: String, newTitle: String){
        let ref = self.db.collection("users").document(userId) .collection("lists").document(listId)
        ref.updateData([
            "title": newTitle
            ]){ err in
                if let err = err{
                    print("Error updating list: \(err)")
                }else{
                    print("updated list with Id: \(ref.documentID)")
                }
            }
    }
    
    func updateTitleInPlaces(userId:String, oldTitle: String, newTitle: String, places: [Place]){
        for place in places{
            if let index = place.list.firstIndex(of: oldTitle) {
                place.list[index] = newTitle
            }
            placeDbController.updatePlace(userId: userId, place: place, listTitle: place.list)
        }
    }

    func getAllList(userId:String, completion: @escaping ([List]) -> Void){
        var lists = [List]()
        db.collection("users").document(userId).collection("lists").getDocuments(){ (QuerySnapshot,err) in
            if let err = err{
                print("error getting lists: \(err)")
                lists = []
            }else{
                for doc in QuerySnapshot!.documents{
                    let title = doc.data()["title"] as? String
                    let placeIds = doc.data()["places"] as? [Int]
                        
                    let icon = self.setListIcon(title: title!)
                        
                    let list = List(title: title!, id: doc.documentID, icon: icon.0, color: icon.1, placeIds: placeIds!, count: placeIds?.count ?? 0)
                        
                    lists.append(list)
                    }
            }
            completion(lists)
        }
    }
    
    func deleteList(userId:String, listId: String){
        self.db.collection("users").document(userId) .collection("lists").document(listId).delete(){ err in
            if let err = err{
                print("Error deleting list: \(err)")
            }else{
                print("list delete with Id: \(listId)")
            }
        }
    }
    
    func removePlaceFromAllList(userId:String, placeId: Int, listTitle: [String]){
        self.db.collection("users").document(userId).collection("lists").whereField("title", in: listTitle).getDocuments() { (querySnapshot, err) in
               if let err = err {
                   print("Error getting documents: \(err)")
               } else {
                   for document in querySnapshot!.documents {
                       print("\(document.documentID) => \(document.data())")
                    self.removePlaceFromList(userId: userId, listId: document.documentID, placeId: placeId)
                   }
               }
        }
    }
    
    func removePlaceFromList(userId:String, listId: String, placeId: Int){
          let ref = self.db.collection("users").document(userId) .collection("lists").document(listId)
           ref.updateData([
               "places": FieldValue.arrayRemove([placeId])
           ]){ err in
               if let err = err{
                   print("Error updating list: \(err)")
               }else{
                   print("updated list with Id: \(ref.documentID)")
               }
           }
    }
    
    func removeAllPlaceFromList(userId:String, listId: String, placeIds: [Int]){
             let ref = self.db.collection("users").document(userId) .collection("lists").document(listId)
              ref.updateData([
                "places": FieldValue.arrayRemove(placeIds)
              ]){ err in
                  if let err = err{
                      print("Error updating list: \(err)")
                  }else{
                      print("updated list with Id: \(ref.documentID)")
                  }
          }
    }
}

extension ListDbController {
func setListIcon(title: String)-> (UIImage, UIColor){
         var img = ""
              var color = UIColor.lightPurple
                switch title {
                case "Favourite":
                    img = "heart.circle.fill"
                    color = UIColor.lightRed
                case "To explore":
                    img = "flag.circle.fill"
                    color = UIColor.lightGreen
                case "Starred":
                    img = "star.circle.fill"
                    color = UIColor.lightOrange
                case "Recreational":
                    img = "folder.circle.fill" //"music.house.fill"
                    color = UIColor.lightTeal
                default:
                    img = "folder.circle.fill" //"list.bullet"
                }
         let image = UIImage(systemName: img)
         return (image!, color)
     }
}

