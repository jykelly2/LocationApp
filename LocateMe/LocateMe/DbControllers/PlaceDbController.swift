//
//  LocationDbController.swift
//  LocateMe
//
//  Created by Jun K on 2020-12-23.
//  Copyright © 2020 JK. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import MapKit

public class PlaceDbController{
    
    let group = DispatchGroup()
       var db : Firestore!
       
       init() {
           let settings = FirestoreSettings()
           Firestore.firestore().settings = settings
           db = Firestore.firestore()
       }

    func addPlaceToHistory(place: Place, userId:String, listTitle: [String], count: Int){
           let geoPoint = GeoPoint(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
              var ref : DocumentReference? = nil
              ref = self.db.collection("users").document(userId) .collection("history").addDocument(data: [
                   "name" : place.name,
                   "address" : place.address,
                   "category" : place.category,
                   "phone" : place.phone,
                   "website" : place.website!.absoluteString ,
                   "coordinate" : geoPoint,
                   "list": listTitle,
                   "id": count,
              ]){ err in
                  if let err = err{
                      print("Error adding place: \(err)")
                  }else{
                   guard let documentId = ref?.documentID else {return}
                      print("place added with Id: \(documentId)")
                  }
              }
    }
    
    func removeListFromAllPlaces(userId:String, listTitle: String, completion: @escaping (Int) -> Void) {
        self.db.collection("users").document(userId).collection("history").whereField("list", arrayContains: listTitle).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let list = document.data()["list"] as? [String]
                        
                        if list?.count == 1 {
                            self.deletePlace(userId: userId, placeId: document.documentID)
                            completion((document.data()["id"] as? Int)!)
                        }else{
                            self.removeListInPlace(userId: userId, placeId: document.documentID, listTitle: listTitle)
                        }
                    }
                }
         }
     }
    
    func removeListFromAllSelectedPlaces(userId:String, listId: String, listTitle: String, places: [Place]) {
        for place in places{
            if place.list.count == 1 {
                self.deletePlace(userId: userId, placeId: place.dbId)
            }else{
                self.removeListInPlace(userId: userId, placeId: place.dbId, listTitle: listTitle)
            }
        }
    }
    
    func removeListInPlace(userId:String, placeId: String, listTitle: String){
        let ref = self.db.collection("users").document(userId) .collection("history").document(placeId)
             ref.updateData([
                 "list": FieldValue.arrayRemove([listTitle])
             ]){ err in
                 if let err = err{
                     print("Error editing place list: \(err)")
                 }else{
                     print("updated place with Id: \(ref.documentID)")
                 }
        }
    }
    
    func updatePlace(userId:String, place: Place, listTitle: [String]){
        let geoPoint = GeoPoint(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        self.db.collection("users").document(userId).collection("history").document(place.dbId).setData([
            "name" : place.name,
            "address" : place.address,
            "category" : place.category,
            "phone" : place.phone,
            "website" : place.website!.absoluteString ,
            "coordinate" : geoPoint,
            "list": listTitle,
            "id": place.id])
            { err in
                if let err = err{
                    print("Error updating place: \(err)")
                }else{
                    print("updated place with Id: \(place.dbId)")
            }
       }
    }
    
    func getAllPlaces(userId:String, completion: @escaping ([Place]) -> Void)
               {
                //.limit(to:10)
                var places = [Place]()
                db.collection("users").document(userId).collection("history").order(by: "id", descending: true).getDocuments(){ (QuerySnapshot,err) in
               if let err = err{
                   print("error getting places: \(err)")
                   places = []
               }else{
                for doc in QuerySnapshot!.documents{
                    let name = doc.data()["name"] as? String
                    let address = doc.data()["address"] as? String
                    let category = doc.data()["category"] as? String
                    let phone = doc.data()["phone"] as? String
                    let website = doc.data()["website"] as? String
                    let id = doc.data()["id"] as? Int
                    let list = doc.data()["list"] as? [String]
                    let geoPoint = doc.data()["coordinate"] as? GeoPoint
                    
                    guard let location = geoPoint else {return}
                    
                    let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                  
                    let icon = self.setPlaceIcon(title: category!)
                    
                    let place = Place(name: name!, address: address!, phone: phone!, website: URL(string: website!)!, category: category!, coordinate: coordinate, id: id!, dbId: doc.documentID, list: list!, icon: icon.0, color: icon.1)
                    
                    places.append(place)
                 }
               }
               completion(places)
           }
       }
    
    func getAllPlacesForList(userId:String, listTitle: String, completion: @escaping ([Place]) -> Void){
             var places = [Place]()
             db.collection("users").document(userId).collection("history").whereField("list", arrayContains: listTitle).getDocuments(){ (QuerySnapshot,err) in
            if let err = err{
                print("error getting places: \(err)")
                places = []
            }else{
             for doc in QuerySnapshot!.documents{
                 let name = doc.data()["name"] as? String
                 let address = doc.data()["address"] as? String
                 let category = doc.data()["category"] as? String
                 let phone = doc.data()["phone"] as? String
                 let website = doc.data()["website"] as? String
                 let id = doc.data()["id"] as? Int
                 let list = doc.data()["list"] as? [String]
                 let geoPoint = doc.data()["coordinate"] as? GeoPoint
                 
                 guard let location = geoPoint else {return}
                 
                 let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
               
                 let icon = self.setPlaceIcon(title: category!)
                 
                 let place = Place(name: name!, address: address!, phone: phone!, website: URL(string: website!)!, category: category!, coordinate: coordinate, id: id!, dbId: doc.documentID, list: list!, icon: icon.0, color: icon.1)
                 
                 places.append(place)
              }
            }
            completion(places)
        }
    }
    
    func getPlaceByAddress(userId: String, place: Place, completion: @escaping (Place) -> Void){
        let docRef = db.collection("users").document(userId).collection("history").whereField("address",  isEqualTo: place.address).limit(to: 1)
        docRef.getDocuments(){ (QuerySnapshot,err) in
            if let err = err{
                print("error getting place: \(err)")
                completion(place)
            }else{
                if !((QuerySnapshot?.documents.isEmpty)!){
                if let doc = QuerySnapshot?.documents[0],  let name = doc.data()["name"] as? String,
                    let address = doc.data()["address"] as? String,
                    let category = doc.data()["category"] as? String,
                    let phone = doc.data()["phone"] as? String,
                    let website = doc.data()["website"] as? String,
                    let id = doc.data()["id"] as? Int,
                    let list = doc.data()["list"] as? [String],
                    let geoPoint = doc.data()["coordinate"] as? GeoPoint {
               
                 let coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
               
                 let icon = self.setPlaceIcon(title: category)
                 
                 let dbPlace = Place(name: name, address: address, phone: phone, website: URL(string: website)!, category: category, coordinate: coordinate, id: id, dbId: doc.documentID, list: list, icon: icon.0, color: icon.1)
                 
                completion(dbPlace)
              }
            }
            }
        }
        
    }
    
    func getAllPlacesIds(userId:String, completion: @escaping ([Int]) -> Void){
            var ids = [Int]()
            db.collection("users").document(userId).collection("history").order(by: "id", descending: true).getDocuments(){ (QuerySnapshot,err) in
                  if let err = err{
                      print("error getting places: \(err)")
                  }else{
                     for doc in QuerySnapshot!.documents{
                        guard let id = doc.data()["id"] as? Int else{return}
                        ids.append(id)
                    }
                  }
                  completion(ids)
              }
    }
  
    func deletePlace(userId:String, placeId: String){
        self.db.collection("users").document(userId) .collection("history").document(placeId).delete(){ err in
            if let err = err{
                print("Error deleting place: \(err)")
            }else{
                print("place deleted with Id: \(placeId)")
            }
        }
    }
}

extension PlaceDbController {
    func setPlaceIcon(title: String)-> (UIImage, UIColor){
           var img = ""
                  var color = UIColor.lightRed
                  switch title {
                  case "Gas Station":
                      img = "gasicon"
                      color = UIColor.lightBlue
                  case "Restaurant":
                      img = "restauranticon"
                      color = UIColor.lightOrange
                  case "Park":
                      img = "parkicon"
                      color = UIColor.lightGreen
                  default:
                      img = "locationicon"
                  }
           let image = UIImage(named: img)?.withRenderingMode(.alwaysTemplate)
           return (image!, color)
    }
}

