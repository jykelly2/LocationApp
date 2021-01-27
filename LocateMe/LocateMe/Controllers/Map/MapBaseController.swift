//
//  MyMapDelegate.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-22.
//  Copyright © 2021 JK. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FloatingPanel

enum FpcType{
    case search
    case list
    case place
}

// MARK: - Map SuperClass (Inherited by MapController and ListController)
class MapBaseController : UIViewController, FloatingPanelControllerDelegate{
    lazy var listDetailVC = storyboard?.instantiateViewController(withIdentifier: "ListDetailController") as! ListDetailController
    
    let myMap = MKMapView()
    var currentLocation: CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
    
    var originalMapRect: MKMapRect?
    var selectedAnnotation: MKAnnotation?
    
    let fpc = FloatingPanelController()
    let detailFpc = FloatingPanelController()
    let infoFpc = FloatingPanelController()

    var matchingPlaces: [Place] = []
    var list: List?
    
    var userId: String = ""
    
    var modifyingMap = false
    var appIsModifying: Bool = false
    
    var tableViewSelect: Bool = false
    
// MARK: - MKMapView Functions
        
    func setupMapView(fromMap: Bool) {
        myMap.delegate = self
        //setup map appearance
        myMap.mapType = MKMapType.standard
        myMap.isZoomEnabled = true
        myMap.isScrollEnabled = true
        myMap.isUserInteractionEnabled = true
        myMap.showsScale = true
        myMap.showsCompass = false
            
        view.addSubview(myMap)
        view.sendSubviewToBack(myMap)
        myMap.bounds = view.bounds
        myMap.center = view.center
        //set up locationmanager properties
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
                      
        //start getting the location updates using the callback created
        if (CLLocationManager.locationServicesEnabled()){
            locationManager.startUpdatingLocation()
        }
        if fromMap{
            guard let location = locationManager.location else { return }
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            setMapToInitialZoom(span: span, location: location)
            myMap.showsUserLocation = true
            myMap.setUserTrackingMode(.followWithHeading, animated: true)
        }

    }
            
    func setMapToInitialZoom(span: MKCoordinateSpan, location: CLLocation){
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        myMap.setRegion(region, animated: true)
        
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 260, right: 0)
        self.myMap.setVisibleMapRect(self.myMap.visibleMapRect, edgePadding: padding, animated: false)
    }
    
    func zoomInToCordinate(coordinate: CLLocationCoordinate2D){
        var span = myMap.region.span
        span.latitudeDelta *= 0.08
        span.longitudeDelta *= 0.08
           
        let region = MKCoordinateRegion(center: coordinate, span: span)
        myMap.setRegion(region, animated: false)
           
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        
        self.myMap.setVisibleMapRect(self.myMap.visibleMapRect, edgePadding: padding, animated: false)
        appIsModifying = true
    }
      
    func zoomToOriginal(){
        myMap.deselectAnnotation(selectedAnnotation, animated: true)
        self.myMap.setVisibleMapRect(originalMapRect ?? myMap.visibleMapRect, animated: false)
    }
       
    func getSamePlace(coordinate: CLLocationCoordinate2D) -> Place?{
        return matchingPlaces.first(where: {$0.coordinate == coordinate})
    }
       
    func addAnotation(place: Place){
        let myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = place.coordinate
        myAnnotation.title = place.name
        myAnnotation.subtitle = place.category
        self.myMap.addAnnotation(myAnnotation)
    }
       
    func animateAnnotation(coordinate: CLLocationCoordinate2D){
        let selectedAnnotation = myMap.annotations.first(where: {$0.coordinate == coordinate})
           
        self.selectedAnnotation = selectedAnnotation
        myMap.selectAnnotation(selectedAnnotation!, animated: true)
        tableViewSelect = false
          
        zoomInToCordinate(coordinate: coordinate)
    }

// MARK: - FloatingPanel Functions
    
    func layoutPanelForPad(fpc: FloatingPanelController) {
        fpc.behavior = SearchPaneliPadBehavior()
        view.addSubview(fpc.view)
        addChild(fpc)
            
        fpc.view.frame = view.bounds // Needed for a correct safe area configuration
        fpc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fpc.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
            fpc.view.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0 ),
            fpc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
            fpc.view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0),
        ])
        fpc.show(animated: false) { [weak self] in
            guard let self = self else { return }
            self.didMove(toParent: self)
        }
        fpc.setAppearanceForPad()
    }

    func layoutPanelForPhone(fpc: FloatingPanelController, type: FpcType) {
        switch type {
        case .search:
            fpc.layout  = SearchDetailPanelLayout()
        case .list:
            fpc.layout  = ListDetailPanelLayout()
        default:
            fpc.layout  = PlaceDetailPanelLayout()
        }
            
        fpc.surfaceView.grabberHandle.isHidden = type == FpcType.list ? true : false
        fpc.addPanel(toParent: self, animated: true)
        fpc.setAppearanceForPhone()
    }
      
}


