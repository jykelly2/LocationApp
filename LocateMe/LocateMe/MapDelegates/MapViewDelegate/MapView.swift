//
//  MapViewDelegate.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-26.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FloatingPanel

// MARK: - MapBaseController Map functions

extension MapBaseController:  MKMapViewDelegate{
     func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
         if let mapPolyline = overlay as? MKPolyline {
             let polyLineRenderer = MKPolylineRenderer(polyline: mapPolyline)
             polyLineRenderer.strokeColor = .teal
             polyLineRenderer.lineWidth = 4.0
             
             return polyLineRenderer
         }
         if let circleOverlay = overlay as? MKCircle {
             let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
             circleRenderer.fillColor = .teal
             circleRenderer.alpha = 0.8

             return circleRenderer
         }
         fatalError("Polyline Renderer could not be initialized" )
     }
               
            
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
         guard !(annotation is MKUserLocation) else { return nil }
         let reuseId = "annotation"
         var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
         if pinView == nil {
             pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
         }
         pinView?.clusteringIdentifier = "cluster"
         let icon = self.setPlaceIcon(title: (annotation.subtitle ?? "location")!)
            
         pinView?.markerTintColor = icon.1
         pinView?.glyphImage = icon.0
         pinView?.glyphTintColor = .white
         pinView?.animatesWhenAdded = true
           
         return pinView
     }
         
     func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
         if mapView.camera.altitude <= 6000 && !modifyingMap && appIsModifying == true{
             modifyingMap = true
             mapView.camera.altitude = 2000
             modifyingMap = false
         }
         appIsModifying = false
     }
}
// MARK: - MapController Map functions

extension MapController {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
           guard !(tableViewSelect == true) else { return }
          // infoFpc.removePanelFromParent(animated: true)
           if view.annotation is MKClusterAnnotation{
               let actionSheetController: UIAlertController = UIAlertController(title: "Open details for:", message: nil, preferredStyle: .actionSheet)
               
               if let annotations = view.annotation as? MKClusterAnnotation {
                   for annotation in annotations.memberAnnotations{
                       let action: UIAlertAction = UIAlertAction(title: annotation.title!, style: .default) { action -> Void in
                           if let place = self.getSamePlace(coordinate: annotation.coordinate){
                               self.getDistanceAndTime(place: place)
                              // self.zoomInToCordinate(coordinate: annotation.coordinate)
                           }
                       }
                       actionSheetController.addAction(action)
                   }
               }
                 let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
               actionSheetController.addAction(cancelAction)
               actionSheetController.popoverPresentationController?.sourceView = self.view
               present(actionSheetController, animated: true)
               
           }
           else{
               guard let annotation = view.annotation else {return}
               if let tappedItem = getSamePlace(coordinate: annotation.coordinate) {
                   self.getDistanceAndTime(place: tappedItem)
               }
           }
    }
    
   func adjustMap(places: [Place]){
               self.addPinsToMap(places: places)
               self.myMap.showAnnotations(self.myMap.annotations, animated: true)
               let padding = UIEdgeInsets(top: 50, left: 50, bottom: 280, right: 50)
               self.myMap.setVisibleMapRect(self.myMap.visibleMapRect, edgePadding: padding, animated: false)
               self.originalMapRect = self.myMap.visibleMapRect
    }
    
    func addPinsToMap(places: [Place]){
          for place in places {
              addAnotation(place: place)
          }
    }
      
    func addSinglePinToMap(place: Place){
        print("placecountinannotation\(matchingPlaces.count)")
        addAnotation(place: place)
        matchingPlaces.append(place)
    }
      
}

    
// MARK: - ListController Map functions

extension ListController{
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
               guard !(tableViewSelect == true) else { return }
              // infoFpc.removePanelFromParent(animated: true)
               if view.annotation is MKClusterAnnotation{
                   let actionSheetController: UIAlertController = UIAlertController(title: "Open details for:", message: nil, preferredStyle: .actionSheet)
                   
                   if let annotations = view.annotation as? MKClusterAnnotation {
                       for annotation in annotations.memberAnnotations{
                           let action: UIAlertAction = UIAlertAction(title: annotation.title!, style: .default) { action -> Void in
                               if let place = self.getSamePlace(coordinate: annotation.coordinate){
                                   self.getDistanceAndTime(place: place)
                                  // self.zoomInToCordinate(coordinate: annotation.coordinate)
                               }
                           }
                           actionSheetController.addAction(action)
                       }
                   }
                     let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
                   actionSheetController.addAction(cancelAction)
                   actionSheetController.popoverPresentationController?.sourceView = self.view
                   present(actionSheetController, animated: true)
                   
               }
               else{
                   guard let annotation = view.annotation else {return}
                   if let tappedItem = getSamePlace(coordinate: annotation.coordinate) {
                       self.getDistanceAndTime(place: tappedItem)
                   }
               }
    }
}
