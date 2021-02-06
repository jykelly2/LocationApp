//
//  ListController.swift
//  LocateMe
//
//  Created by Jun K on 2020-11-13.
//  Copyright © 2020 JK. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FloatingPanel

class ListMapController: MapBaseController{
    typealias PanelDelegate = FloatingPanelControllerDelegate & UIGestureRecognizerDelegate
    
    lazy var fpcDelegate: PanelDelegate =
        (traitCollection.userInterfaceIdiom == .pad) ? SearchPanelPadDelegate(mapOwner: nil, fpcType: .list) : SearchPanelPhoneDelegate(mapOwner: nil, listOwner: self)
    
    lazy var placeFpcDelegate: PanelDelegate =
        (traitCollection.userInterfaceIdiom == .pad) ? SearchPanelPadDelegate(mapOwner: nil, fpcType: .place) : SearchPanelPhoneDelegate(mapOwner: nil, listOwner: self)
    
    var currentPlace: Place?
    var count = 0
    var mapBottomInset = 0.0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(animated: animated)
        
        if matchingPlaces.count > 0 && count == 0{
            for item in matchingPlaces{
                addAnotation(place: item)
                let destPlacemark = MKPlacemark(coordinate: item.coordinate)
                let distance = self.locationManager.location?.distance(from: destPlacemark.location!)
                item.distance = Double(distance ?? 0)
            }
            
            myMap.showAnnotations(self.myMap.annotations, animated: true)
            self.mapBottomInset = 280
            count += 1
        }
        
        if let currentPlace = currentPlace{
            addAnotation(place: currentPlace)
            myMap.showAnnotations(self.myMap.annotations, animated: false)
            self.mapBottomInset = 240
        }
        
        let padding = traitCollection.userInterfaceIdiom == .pad ? UIEdgeInsets(top: 50, left: 425, bottom: 50, right: 50) : UIEdgeInsets(top: 50, left: 50, bottom: 280, right: 50)
        self.myMap.setVisibleMapRect(self.myMap.visibleMapRect, edgePadding: padding, animated: false)
        originalMapRect = self.myMap.visibleMapRect
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView(fromMap: false)
        setUpView()
    }
    
    func setUpView(){
        if currentPlace == nil{
            fpc.delegate = fpcDelegate
            fpc.contentMode = .fitToBounds
            
            listDetailVC.list = list
            listDetailVC.places = matchingPlaces
            listDetailVC.userId = userId
            
            fpc.set(contentViewController: listDetailVC)
            fpc.track(scrollView: listDetailVC.tableView)
            setUpFloatingPanel(fpc: fpc, type: FpcType.list)
            
            setUpDetailView()
        }else{
            getDistanceAndTime(place: currentPlace!)
        }
    }
    
    func setUpFloatingPanel(fpc: FloatingPanelController , type: FpcType){
        switch traitCollection.userInterfaceIdiom {
        case .pad:
            layoutPanelForPad(fpc: fpc)
            fpc.panGestureRecognizer.delegateProxy = fpcDelegate
        default:
            layoutPanelForPhone(fpc: fpc, type: type)
        }
    }
    
}

// MARK: - Place Detail View Setup
extension ListMapController: UITableViewDelegate{
    func setUpDetailView() {
        listDetailVC.loadViewIfNeeded()
        listDetailVC.tableView.delegate = self
        listDetailVC.tableView.isUserInteractionEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.infoFpc.removePanelFromParent(animated: true)
        guard let place = listDetailVC.places?[indexPath.row] else {return}
        self.tableViewSelect = true
        getDistanceAndTime(place: place)
    }
    
    func getDistanceAndTime(place: Place){
        let destPlacemark = MKPlacemark(coordinate: place.coordinate)
        let soucePlacemark = MKPlacemark(coordinate: self.locationManager.location!.coordinate)
        let destItem = MKMapItem(placemark: destPlacemark)
        let sourceItem = MKMapItem(placemark: soucePlacemark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destItem
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate { (response, error) in
            guard response != nil else {
                if error != nil {
                    print("error\(error)")
                }
                return
            }
            guard let route = response?.routes[0] else{return}
            let minutes = route.expectedTravelTime / 60
            let time = Int(ceil(minutes)).description
            place.distance = Double(route.distance)
            place.time = time
            
            self.fpc.hide(animated: false, completion: {self.fpc.view.isHidden = true})
            self.setUpPlaceDetail(place: place)
        }
    }
    
    func setUpPlaceDetail(place: Place){
        let placeDetailVC = storyboard?.instantiateViewController(withIdentifier: "PlaceDetailController") as! PlaceDetailController
        placeDetailVC.currentPlace = place
        placeDetailVC.currentList = self.list
        placeDetailVC.userId = self.userId
        
        infoFpc.delegate = placeFpcDelegate
        infoFpc.contentMode = .fitToBounds
        infoFpc.set(contentViewController: placeDetailVC)
        infoFpc.track(scrollView: placeDetailVC.tableView)
        setUpFloatingPanel(fpc: infoFpc, type: FpcType.place)
        
        if self.list != nil{
            placeDetailVC.CloseBtn.addTarget(self, action: #selector(removeInfoFpc), for: .touchUpInside)
        }
        
        animateAnnotation(coordinate: place.coordinate)
    }
    
    @objc func removeInfoFpc(){
        infoFpc.removePanelFromParent(animated: false)
        
        let placeDetailView = PlaceDetailController()
        placeDetailView.didMove(toParent: nil)
        placeDetailView.view.removeFromSuperview()
        placeDetailView.removeFromParent()
        placeDetailView.dismiss(animated: false)
        
        fpc.view.isHidden = false
        fpc.show(animated: true)
        self.zoomToOriginal()
    }
    
}


