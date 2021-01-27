//
//  MyMapLocationManager.swift
//  LocateMe
//
//  Created by Jun K on 2021-01-22.
//  Copyright © 2021 JK. All rights reserved.
//

import MapKit
import CoreLocation


extension MapBaseController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedWhenInUse:
                 locationManager.requestLocation()
             case .authorizedAlways:
                 break
             case .denied:
                 break
             case .notDetermined:
                 locationManager.requestWhenInUseAuthorization()
                 locationManager.requestLocation()
             @unknown default:
                 break
             }
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("memory warning from location")
    }
}
extension MapController{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !(trace == traceState.neutral),let location = locations.first else {return}
        
        if trace == traceState.start{
            coordinates.append(location.coordinate)
        }else if trace == traceState.restart && coordinates.count > 0{
            coordinates.removeAll()
            myMap.removeOverlays(myMap.overlays)
            
            trace = traceState.neutral
        }else{
            if coordinates.count > 0{
                let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                         
                var regionRect = polyline.boundingMapRect
                          
                let wPadding = regionRect.size.width * 0.25
                let hPadding = regionRect.size.height + 270

                regionRect.origin.x -= wPadding / 2
                
                //Add padding to the region
                regionRect.size.width += wPadding
                regionRect.size.height += hPadding

                myMap.setRegion(MKCoordinateRegion(regionRect), animated: true)
                trace = traceState.neutral
            }
        }
    }
}
