//
//  GetDirectionViewController.swift
//  Pointters
//
//  Created by super on 5/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import MapKit

class GetDirectionViewController: UIViewController {

    @IBOutlet weak var consNavViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    
    var serviceLocation = Location.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        getDirection()
    }
    
    //*******************************************************//
    //              MARK: - Private Method                   //
    //*******************************************************//
    
    func initUI() {
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavViewHeight.constant = 85.0
        } else {
            consNavViewHeight.constant = 64.0
        }
    }
    
    func getDirection() {
        let sourceLocation = CLLocationCoordinate2D(latitude: UserCache.sharedInstance.getUserLatitude()!, longitude: UserCache.sharedInstance.getUserLongitude()!)
        let destinationLocation = CLLocationCoordinate2D(latitude: serviceLocation.geoJson.coordinates[1], longitude: serviceLocation.geoJson.coordinates[0])
        // 3.
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        // 4.
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // 5.
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "User Location"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "Service Location"
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        // 6.
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        // 7.
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 8.
        directions.calculate(completionHandler: {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        })
    }
    
    //    *******************************************************//
    //                  MARK: - IBAction Method                  //
    //    *******************************************************//
    
    @IBAction func btnBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension GetDirectionViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
}






