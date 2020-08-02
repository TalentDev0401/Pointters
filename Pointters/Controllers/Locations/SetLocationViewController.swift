//
//  SetLocationViewController.swift
//  Pointters
//
//  Created by C on 7/7/18.
//  Copyright © 2018 Kenji. All rights reserved.
//

import UIKit
import MapKit

protocol SetLocationVCDelegate {
    func selectedLocation(location: Location)
    func backWithStreet(street: String)
}

class SetLocationViewController: UIViewController {

    @IBOutlet var consNavBarHeight: NSLayoutConstraint!
    @IBOutlet var addressTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!

    var keyword = ""
    var locationDelegate : SetLocationVCDelegate?

    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        
        searchCompleter.delegate = self
        searchBar.setImage(UIImage(named: "icon-search-location"), for: .search, state: .normal)
        
        if PointtersHelper.sharedInstance.checkiPhonX() {
            consNavBarHeight.constant = 137.0
        } else {
            consNavBarHeight.constant = 116.0
        }
        searchBar.becomeFirstResponder()
        self.searchBar.text = keyword
        self.searchBar(self.searchBar, textDidChange: keyword)
    }
    
    func getCoordinate( addressString : String,  completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
//        self.locationDelegate?.backWithStreet(street: searchCompleter.queryFragment)
        navigationController?.popViewController(animated: true)
    }

}


// MARK: - UITableViewDataSource

extension SetLocationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.groupTableViewBackground
        
        let headerLabel = UILabel(frame: CGRect(x: 13, y: 25, width: tableView.bounds.size.width - 30, height: 20))
        headerLabel.font = UIFont(name: "Helvetica", size: 14)
        headerLabel.textColor = UIColor.getCustomGrayTextColor()
        headerLabel.text = "SUGGESTED LOCATIONS"
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as! LocationCell
        let searchResult = searchResults[indexPath.row]
        cell.labelAddress?.text = searchResult.title
        cell.labelAddressDetail?.text = searchResult.subtitle
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SetLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearchRequest(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            
            if self.locationDelegate != nil {
                
                let location = Location.init()
                if ((response?.mapItems[0].placemark.locality) == nil){
                    location.city = ""
                }else{
                    location.city = (response?.mapItems[0].placemark.locality)!
                }
                location.country = (response?.mapItems[0].placemark.country)!
                if ((response?.mapItems[0].placemark.postalCode) == nil){
                    location.postalCode = ""
                }else{
                    location.postalCode = (response?.mapItems[0].placemark.postalCode)!
                }
                
                location.state = (response?.mapItems[0].placemark.administrativeArea != nil ? response?.mapItems[0].placemark.administrativeArea : "")!
                location.province = (response?.mapItems[0].placemark.subAdministrativeArea != nil ? response?.mapItems[0].placemark.subAdministrativeArea : "")!
                location.street = (response?.mapItems[0].placemark.postalAddress?.street != nil ? response?.mapItems[0].placemark.postalAddress?.street : "")!
                
                let geo = GeoJson.init()
                geo.type = "Point"
                if (response?.mapItems[0].placemark.coordinate != nil) {
                    geo.coordinates = [response?.mapItems[0].placemark.coordinate.longitude, response?.mapItems[0].placemark.coordinate.latitude] as! [Double]
                }
                location.geoJson = geo
                self.locationDelegate?.selectedLocation(location: location)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension SetLocationViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
        self.addressTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
}

extension SetLocationViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchCompleter.queryFragment = searchBar.text!
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
}

extension SetLocationViewController : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}
