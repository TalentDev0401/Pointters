//
//  ServiceDetailCell.swift
//  Pointters
//
//  Created by super on 3/19/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import MapKit

class ServiceDetailCell: UITableViewCell, MKMapViewDelegate {
    
    // price cell
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnDown: UIButton!
    
    // delivery cell
    @IBOutlet weak var lblFulfillment: UILabel!
    @IBOutlet weak var mkMapView: MKMapView!
    @IBOutlet weak var btnGetDirections: UIButton!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
    
    // time cell
    @IBOutlet weak var lblDeliveryTime: UILabel!
    
    // review cell
    @IBOutlet weak var imgBuyerPic: UIImageView!
    @IBOutlet weak var lblBuyerName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblQuality: UILabel!
    @IBOutlet weak var imgOnTime: UIImageView!
    @IBOutlet weak var imgBuyAgain: UIImageView!
    
    // Read More Cell
    @IBOutlet weak var lblReadMore: UILabel!
    
    // Flag Cell
    @IBOutlet weak var btnFlagInappriate: UIButton!
    @IBOutlet weak var imageFlag: UIImageView!
    @IBOutlet weak var labelFlag: UILabel!
    
    
    var isLocalService = false
    var localRadius = 15

    override func awakeFromNib() {
        super.awakeFromNib()
        if mkMapView != nil {
            mkMapView!.showsPointsOfInterest = true
            mkMapView.delegate = self
            mkMapView.hideAttributedView()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func showLocation(lat: Double, lng: Double) {
        let orgLocation = CLLocationCoordinate2DMake(lat, lng)
        let viewRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(orgLocation, 500, 500)
        let point = MKPointAnnotation()
        point.coordinate = orgLocation
        self.mkMapView.delegate = self
        self.mkMapView?.addAnnotation(point)
        self.mkMapView?.setRegion(viewRegion, animated:true)
        if isLocalService == true {
            showCircle(location: CLLocation(latitude: lat, longitude: lng), radius: CLLocationDistance(localRadius) * 1600, mapView: self.mkMapView)
        }
    }
    
    func showStoreLocations(locations: [[String: Any]]) {
        let firstLocation = locations[0]
        if let geoJSON = firstLocation["geoJson"] as? [String:Any] {
            let coordinates = geoJSON["coordinates"] as! [Double]
            let orgLocation = CLLocationCoordinate2DMake(coordinates[1], coordinates[0])
            let viewRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(orgLocation, 500, 500)
            self.mkMapView?.setRegion(viewRegion, animated:true)
            self.mkMapView.delegate = self
            for location in locations {
                if let geo = location["geoJson"] as? [String:Any] {
                    let coords = geo["coordinates"] as! [Double]
                    let org = CLLocationCoordinate2DMake(coords[1], coords[0])
                    let point = MKPointAnnotation()
                    point.coordinate = org
                    self.mkMapView?.addAnnotation(point)
                }
            }
        }
    }
    
    func showFulfillmentMap(buyerLocation: Location, sellerLocation: Location) {
        let lat_buyer = buyerLocation.geoJson.coordinates[1]
        let lng_buyer = buyerLocation.geoJson.coordinates[0]
        let orgLocation = CLLocationCoordinate2DMake(lat_buyer, lng_buyer)
        let viewRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(orgLocation, 500, 500)
        let point = MKPointAnnotation()
        point.coordinate = orgLocation
        self.mkMapView.delegate = self
        self.mkMapView?.addAnnotation(point)
        self.mkMapView?.setRegion(viewRegion, animated:true)
        
        let lat_seller = sellerLocation.geoJson.coordinates[1]
        let lng_seller = sellerLocation.geoJson.coordinates[0]
        let sellerLoc = CLLocationCoordinate2DMake(lat_seller, lng_seller)
        let sellerPoint = MKPointAnnotation()
        sellerPoint.coordinate = sellerLoc
        self.mkMapView.addAnnotation(sellerPoint)
        self.showCircle(location: CLLocation(latitude: lat_seller, longitude: lng_seller), radius: CLLocationDistance(localRadius) * 1600, mapView: self.mkMapView)
    }
    
    func showCircle(location: CLLocation, radius: CLLocationDistance, mapView: MKMapView) {
        let circle = MKCircle(center:location.coordinate, radius: radius)
        mapView.add(circle)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.clear
            circle.fillColor = UIColor.getCustomBlueColor()
            circle.alpha = 0.2
            return circle
        } else {
            return MKPolylineRenderer()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't do anything if it's the users location
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = self.mkMapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        
        if annotationView == nil {
            if annotation is CustomPointAnnotation {
                annotationView = CustomPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
                annotationView?.canShowCallout = false
                annotationView?.image = UIImage(named:"icon-pin-round")
            } else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
                annotationView?.canShowCallout = false
                annotationView?.image = UIImage(named:"icon-pin-round")
            }
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {

    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }

}

extension MKMapView {
    var attributedView: UIView? {
        for subview in subviews {
            if String(describing: type(of: subview)).contains("Label") {
                return subview
            }
        }
        return nil
    }
    
    func hideAttributedView() {
        guard let attributedView = attributedView else {
            return
        }
        attributedView.isHidden = true
    }
}
