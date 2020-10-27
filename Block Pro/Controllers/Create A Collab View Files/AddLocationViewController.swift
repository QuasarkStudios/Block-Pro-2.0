//
//  AddLocationViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/17/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SVProgressHUD

class AddLocationViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    
    lazy var locationSearchView = LocationSearchView(parentViewController: self)
    lazy var searchViewHeightConstraint = locationSearchView.constraints.first(where: { $0.firstAttribute == .height })
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    
    var locationSearchResults: [MKMapItem] = []
    
    var searchResultSelected: Bool = false
    var selectedLocation: MKMapItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UIApplication.shared.statusBarStyle = .default
        
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 85, right: 0)
        
        self.title = "Add a Location"
        
        self.view.addSubview(locationSearchView)
        
        
        mapView.delegate = self
        mapViewHeightConstraint.constant = self.view.frame.height - 100 //100 is the height of the searchView - 20 to tuck the mapView 20 points under the searchView
        
        checkLocationServices()
        
        configureGestureRecognizors()
    }
    
    private func configureLocationManager () {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    
    private func configureGestureRecognizors () {
        
        locationSearchView.panGestureView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))))
        locationSearchView.searchBar?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))))
    }
    
    private func checkLocationServices () {
        
        if CLLocationManager.locationServicesEnabled() {
            
            configureLocationManager()
            
            checkLocationAuthorization()
        }
        
        else {
            
            //present uialert
        }
    }
    
    private func checkLocationAuthorization () {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedWhenInUse:
            
            mapView.showsUserLocation = true
            
            centerViewOnUserLocation()
            
        case .notDetermined:
            
            locationManager.requestWhenInUseAuthorization()
            break
        
        case .restricted:
            
            //show alert that their moms hates them
            break
            
        case .denied:
            //show alert to tell them to give permission
            break
            
        default:
            break
        }
    }
    
    private func centerViewOnUserLocation () {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            moveWithPan(sender)
            
        case .ended:
            
            if locationSearchView.frame.minY > (self.view.center.y + 100) {
                
                returnToOrigin()
            }
            
            else if locationSearchView.frame.minY < (self.view.center.y + 100) && locationSearchView.frame.minY > (self.view.center.y - 100) {
                
                sendToMiddle()
            }
            
            else if locationSearchView.frame.minY < (self.view.center.y - 100) {
                
                expandView()
            }
            
        default:
            break
        }
    }
    
    private func moveWithPan (_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        if translation.y <= 0 {
            
            let maxHeight = self.view.frame.height - (self.navigationController?.navigationBar.frame.height ?? 0) - 20
            
            if ((searchViewHeightConstraint?.constant ?? 0) + abs(translation.y)) <= maxHeight {
                
                searchViewHeightConstraint?.constant += abs(translation.y)
            }
            
            else {
                
                searchViewHeightConstraint?.constant = maxHeight
            }
        }
        
        else {
            
            if ((searchViewHeightConstraint?.constant ?? 0) - translation.y) >= 120 {
                
                searchViewHeightConstraint?.constant -= translation.y
            }
            
            else {
                
                searchViewHeightConstraint?.constant = 120
            }
        }
        
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    private func returnToOrigin () {
        
        locationSearchView.searchBar?.searchTextField.resignFirstResponder()
        
        searchViewHeightConstraint?.constant = 120
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
        
            self.view.layoutIfNeeded()
            
            self.locationSearchView.locationImageView.alpha = 0
            
        } completion: { (finished: Bool) in
            
        }
    }
    
    private func sendToMiddle () {
        
        searchViewHeightConstraint?.constant = self.view.frame.height / 2
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
        
            self.view.layoutIfNeeded()
            
            self.locationSearchView.locationImageView.alpha = 0//self.locationSearchResults.count > 0 ? 0 : 1
            
        } completion: { (finished: Bool) in
            
        }
    }
    
    private func expandView () {
        
        searchViewHeightConstraint?.constant = self.view.frame.height - (self.navigationController?.navigationBar.frame.height ?? 0) - 20
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
        
            self.view.layoutIfNeeded()
            
//            self.locationSearchView.locationImageView.alpha = self.locationSearchResults.count > 0 ? 0 : 1
            
        } completion: { (finished: Bool) in
            
        }
    }
    
    func searchBegan () {
        
//        searchViewHeightConstraint.constant = self.view.frame.height - (44 + 40)
        
        searchViewHeightConstraint?.constant = self.view.frame.height - (self.navigationController?.navigationBar.frame.height ?? 0) - 20
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
        
            self.view.layoutIfNeeded()
            
        } completion: { (finished: Bool) in
            
        }
    }
    
    func searchTextChanged (searchText: String) {
        
        if searchText.leniantValidationOfTextEntered() {
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            
            let search = MKLocalSearch(request: request)
            search.start { (response, error) in
                
                if error != nil {
                    
    //                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    if let response = response {
                        
                        if let text = self.locationSearchView.searchBar?.searchTextField.text, text.leniantValidationOfTextEntered() {
                            
                            self.locationSearchResults = []
                            
                            var count = 0
                            
                            while count < response.mapItems.count && count < 9 {
                                
                                self.locationSearchResults.append(response.mapItems[count])
                                count += 1
                            }
                            
                            if self.searchResultSelected {
                                
                                self.searchResultSelected = false
                                
                                self.selectedLocation = nil
                                self.locationSearchView.searchTableView.reloadSections([0], with: .fade)
                            }
                            
                            else {
                                
                                self.locationSearchView.searchTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
        else {
            
            locationSearchResults = []
            locationSearchView.searchTableView.reloadData()
        }
    }
    
    func searchEnded () {
        
        if let text = self.locationSearchView.searchBar?.searchTextField.text, text.leniantValidationOfTextEntered() == false {
            
            //115 = gestureIndicatorTopAnchor + gestureIndicator height + searchBarTopAnchor + searchBar height + 20 tableViewTopAnchor + 20 point bottom buffer
            searchViewHeightConstraint?.constant = 120
            
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                
                self.view.layoutIfNeeded()
                
            } completion: { (finished: Bool) in
                
            }
        }
    }
    
    private func parseAddress (_ placemark: MKPlacemark) -> String {
        
        var returnAddress: String = ""
        
        //Street Number
        if let subThoroughfare = placemark.subThoroughfare {
            
            returnAddress = subThoroughfare + " "
        }
        
        //Street Name
        if let thoroughFare = placemark.thoroughfare {
            
            returnAddress += thoroughFare
            returnAddress += ", "
        }
        
        //City
        if let locaility = placemark.locality {
            
            returnAddress += locaility
            returnAddress += ", "
        }
        
        //State
        if let administrativeArea = placemark.administrativeArea {
            
            returnAddress += administrativeArea
            returnAddress += " "
        }
        
        //Zip Code
        if let postalAddress = placemark.postalCode {
            
            returnAddress += postalAddress
        }
        
        return returnAddress
    }
}

extension AddLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
    }
}

extension AddLocationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !searchResultSelected {
            
            return locationSearchResults.count * 2
        }
        
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !searchResultSelected {
            
            if indexPath.row % 2 == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "locationSearchCell", for: indexPath) as! LocationSearchCell
                cell.selectionStyle = .none
                
                cell.locationNameLabel.text = locationSearchResults[indexPath.row / 2].name
                cell.locationAddressLabel.text = parseAddress(locationSearchResults[indexPath.row / 2].placemark)
                
                return cell
            }
            
            else {
                
                let cell = UITableViewCell()
                cell.backgroundColor = .clear
                cell.isUserInteractionEnabled = false
                return cell
            }
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectedLocationCell", for: indexPath) as! SelectedLocationCell
            cell.selectionStyle = .none
            
            if let location = selectedLocation {
                
                cell.locationNameTextField.text = location.name
                cell.locationAddressLabel.text = parseAddress(location.placemark)
                
                cell.cancelLocationSelectionDelegate = self
                cell.navigateToLocationDelegate = self
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if !searchResultSelected {
            
            if indexPath.row % 2 == 0 {
                
                return 55
            }
            
            else {
                
                return 5
            }
        }
        
        else {
            
            return 140
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        searchResultSelected = true
        
        selectedLocation = locationSearchResults[indexPath.row / 2]
        locationSearchView.searchTableView.reloadSections([0], with: .fade)
    }
}


extension AddLocationViewController: CancelLocationSelectionProtocol {
    
    func selectionCancelled () {
        
        searchResultSelected = false
        
        selectedLocation = nil
        locationSearchView.searchTableView.reloadSections([0], with: .fade)
    }
}

extension AddLocationViewController: NavigateToLocationProtocol {
    
    func navigateToLocation() {
        
        guard let location = selectedLocation else { return }
        
            location.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDefault])
    }
}
