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

class AddLocationViewController: UIViewController {

    let mapView = MKMapView()
    
    lazy var locationSearchView = LocationSearchView(parentViewController: self)
    lazy var searchViewHeightConstraint = locationSearchView.constraints.first(where: { $0.firstAttribute == .height })
    
    let locationManager = CLLocationManager()
    
    var locationSearchResults: [MKMapItem] = []
    var locationMapItem: MKMapItem?
    var selectedLocation: Location?
    
    var searchWorkItem: DispatchWorkItem?
    var locationSearch: MKLocalSearch?
    
    var locationPreselected: Bool = false
    var shouldSelectAnnotation: Bool = false
    
    let bottomSafeAreaInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 140 : 160
    let expandedBottomSafeAreaInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 285 : 305
    
    weak var locationSavedDelegate: LocationSavedProtocol?
    weak var cancelLocationSelectionDelegate: CancelLocationSelectionProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add a Location"
        
        configureMapView()
        
        self.view.addSubview(locationSearchView)
        
        //Controll the position of the AppleMaps logo and the legal label of the mapView
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: locationPreselected ? expandedBottomSafeAreaInset : bottomSafeAreaInset, right: 0)
        
        configureLocationManager()
        
        configureGestureRecognizors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if locationPreselected {
            
            locationSet(locationMapItem)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        searchWorkItem = nil //Prevents memory leak
    }
    
    deinit {
        
        print("deinit")
    }
    
    
    //MARK: - Configure MapView
    
    private func configureMapView () {
        
        self.view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.heightAnchor.constraint(equalToConstant: self.view.frame.height)
        
        ].forEach({ $0.isActive = true })
        
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    
    //MARK: - Configure Location Manager
    
    private func configureLocationManager () {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    
    //MARK: - Configure Gesture Recognizors
    
    private func configureGestureRecognizors () {
        
        locationSearchView.panGestureView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))))
        locationSearchView.searchBar?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))))
    }
    
    
    //MARK: - Check Location Services Function
    
    private func checkLocationServices () {
        
        if CLLocationManager.locationServicesEnabled() {
            
            checkLocationAuthorization()
        }
        
        else {
            
            presentDisabledLocationServicesAlert()
        }
    }
    
    
    //MARK: - Check Location Auth Function
    
    private func checkLocationAuthorization () {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedWhenInUse:
            
            centerViewOnUserLocation()
            
        case .notDetermined:
            
            locationManager.requestWhenInUseAuthorization()
        
        case .restricted:
            
            presentRestrictedAlert()
            
        case .denied:
            
            presentDeniedAlert()
            
        default:
            break
        }
    }
    
    
    //MARK: - Center On User Location Function
    
    private func centerViewOnUserLocation () {
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.showsUserLocation = true
        
        if let location = locationManager.location?.coordinate, locationPreselected == false {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    //MARK: - Alert Functions
    
    private func presentDisabledLocationServicesAlert () {
        
        let disabledLocationServicesAlert = UIAlertController(title: "Location Services are Currently Disabled" , message: "You can change this is your settings", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (okAction) in
            
            //Doubles checks to ensure user didn't just turn on location services using the previous system alert
            if !CLLocationManager.locationServicesEnabled() {
                
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        disabledLocationServicesAlert.addAction(okAction)
            
        present(disabledLocationServicesAlert, animated: true, completion: nil)
    }
    
    private func presentRestrictedAlert () {
        
        let restrictedAlert = UIAlertController(title: "\"Block Pro\" cannot access your location due to a certain restriction; possibly a parental one", message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (okAction) in
            
            self.navigationController?.popViewController(animated: true)
        }
        
        restrictedAlert.addAction(okAction)
        
        self.present(restrictedAlert, animated: true)
    }
    
    private func presentDeniedAlert () {
        
        let deniedAlert = UIAlertController(title: "\"Block Pro\" doesn't have access to your location", message: "Would you like to change this in your settings?", preferredStyle: .alert)
        
        let goToSettingsAction = UIAlertAction(title: "Ok", style: .default) { (goToSettingsAction) in
            
            //Opens Block Pro's app settings
            if let appSettings = URL(string: UIApplication.openSettingsURLString)  {
                
                UIApplication.shared.open(appSettings)
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
            
            self.navigationController?.popViewController(animated: true)
        }
        
        deniedAlert.addAction(cancelAction)
        deniedAlert.addAction(goToSettingsAction)
        
        self.present(deniedAlert, animated: true)
    }
    
    
    //MARK: - Handle Pan
    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            moveWithPan(sender)
            
        case .ended:
            
            //If a location hasn't been selected yet
            if locationMapItem == nil {
                
                if locationSearchView.frame.minY > (self.view.frame.height * 0.5) {
                    
                    returnToOrigin()
                }
                
                else {
                    
                    expandView()
                }
            }
            
            else {
                
                sendToSelectedLocationPosition()
            }
            
        default:
            break
        }
    }
    
    
    //MARK: - Move with Pan
    
    private func moveWithPan (_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        //Max height the searchView can be
        let maxHeight = self.view.frame.height - (self.navigationController?.navigationBar.frame.height ?? 0) - 20
        
        //If the searchView is being dragged up
        if translation.y <= 0 {
            
            if ((searchViewHeightConstraint?.constant ?? 0) + abs(translation.y)) <= maxHeight {
                
                searchViewHeightConstraint?.constant += abs(translation.y)
            }
            
            else {
                
                searchViewHeightConstraint?.constant = maxHeight
            }
        }
        
        //If the searchView is being dragged up
        else {
            
            //If a location hasn't been selected yet
            if locationMapItem == nil {
                
                //120 = minimum height when no location has been selected
                if ((searchViewHeightConstraint?.constant ?? 0) - translation.y) >= 120 {
                    
                    searchViewHeightConstraint?.constant -= translation.y
                }
                
                else {
                    
                    searchViewHeightConstraint?.constant = 120
                }
            }
            
            else {
                
                //265 = minimum height when a location has been selected
                if ((searchViewHeightConstraint?.constant ?? 0) - translation.y) >= 265 {
                    
                    searchViewHeightConstraint?.constant -= translation.y
                }
                
                else {
                    
                    searchViewHeightConstraint?.constant = 265
                }
            }
        }
        
        if locationMapItem == nil && locationSearchResults.count == 0 {
            
            transitionLocationImage(maxHeight: maxHeight, searchViewHeight: searchViewHeightConstraint?.constant)
        }
        
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    
    //MARK: - Return to Origin
    
    private func returnToOrigin () {
        
        locationSearchView.searchBar?.searchTextField.resignFirstResponder()
        
        searchViewHeightConstraint?.constant = 120
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
        
            self.view.layoutIfNeeded()
            
            self.locationSearchView.searchTableView.alpha = 0
            self.locationSearchView.locationImageContainer.alpha = 0
            
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.bottomSafeAreaInset, right: 0)
            
        } completion: { (finished: Bool) in
            
            self.locationSearchView.searchTableView.isScrollEnabled = true
        }
    }
    
    
    //MARK: - Send to Selected Position
    
    private func sendToSelectedLocationPosition () {
        
        //Constant is equal to all the heights of the subviews of the locationSearchView + their topAnchors + a 35 point buffer
        searchViewHeightConstraint?.constant = 265
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
        
            self.view.layoutIfNeeded()
            
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.expandedBottomSafeAreaInset, right: 0)
            
        } completion: { (finished: Bool) in
            
            self.locationSearchView.searchTableView.isScrollEnabled = false
        }
        
        guard let cell = locationSearchView.searchTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SelectedLocationCell else { return }
        
            cell.locationNameTextField.resignFirstResponder()
    }
    
    
    //MARK: - Expand View
    
    private func expandView () {
        
        searchViewHeightConstraint?.constant = self.view.frame.height - (self.navigationController?.navigationBar.frame.height ?? 0) - 20
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
        
            self.view.layoutIfNeeded()
            
            self.locationSearchView.searchTableView.alpha = 1
            
            if self.locationSearchResults.count > 0 {
                
                self.locationSearchView.locationImageContainer.alpha = 0
            }
            
            else if let cell = self.locationSearchView.searchTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SelectedLocationCell, cell.locationNameTextField.isFirstResponder {
                
                self.locationSearchView.locationImageContainer.alpha = 0
            }
            
            else {
                
                self.locationSearchView.locationImageContainer.alpha = 1
            }
            
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
        } completion: { (finished: Bool) in
            
            self.locationSearchView.searchTableView.isScrollEnabled = true
        }
    }
    
    
    //MARK: - Search Began Function
    
    func searchBegan () {
        
        if locationMapItem != nil {
            
            selectionCancelled(selectedLocation?.locationID)
        }
        
        expandView()
    }
    
    
    //MARK: - Search Text Changed Function
    
    func searchTextChanged (searchText: String) {
        
        searchWorkItem?.cancel()
        locationSearch?.cancel()
        
        if searchText.leniantValidationOfTextEntered() {
            
            searchWorkItem = DispatchWorkItem(block: {
                
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = searchText
                
                self.locationSearch = MKLocalSearch(request: request)
                self.locationSearch?.start { [weak self] (response, error) in
                    
                    if let response = response {
                        
                        //Double checks to make sure the user hasn't deleted text in searchTextField
                        if let text = self?.locationSearchView.searchBar?.searchTextField.text, text.leniantValidationOfTextEntered() {
                            
                            self?.locationSearchResults = []
                            
                            var count = 0
                            
                            //Limits the amount of results to display to 10
                            while count < response.mapItems.count && count < 9 {
                                
                                self?.locationSearchResults.append(response.mapItems[count])
                                count += 1
                            }
                            
                            self?.locationSearchView.searchTableView.reloadData()
                            self?.animateLocationImage(animateIn: false) {}
                        }
                        
                        //If there is no text in the searchTextField
                        else {
                            
                            self?.animateLocationImage(animateIn: true) {}
                        }
                    }
                    
                    //If no response was recieved
                    else {
                        
                        self?.animateLocationImage(animateIn: true) {}
                    }
                }
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: searchWorkItem!) //Starts the search after a 1/2 second delay
        }
        
        //If the searchTextField is empty
        else {
            
            animateLocationImage(animateIn: true) { 
                
                self.locationSearchResults = []
                self.locationSearchView.searchTableView.reloadData()
            }
        }
    }
    
    
    //MARK: - Search Ended Function
    
    func searchEnded () {
        
        if let text = self.locationSearchView.searchBar?.searchTextField.text, text.leniantValidationOfTextEntered() == false {
            
            returnToOrigin()
        }
        
        else if locationMapItem != nil {
            
            sendToSelectedLocationPosition()
        }
    }
    
    
    //MARK: - Location Set Function
    
    private func locationSet (_ location: MKMapItem?) {
            
        if location != nil {
            
            if locationPreselected {
                
                locationPreselected = false
            }
            
            else {
                
                searchEnded()
                locationSearchView.searchBar?.searchTextField.resignFirstResponder()
                
                saveLocation()
            }
            
            addNewAnnotation(location)
        }
    }
    
    
    //MARK: - Save Location Function
    
    private func saveLocation () {
        
        if let location = locationMapItem {
            
            selectedLocation = Location()
            
            selectedLocation?.locationID = UUID().uuidString
            
            selectedLocation?.placemark = location.placemark
            
            selectedLocation?.coordinates = ["longitude" : location.placemark.coordinate.longitude, "latitude" : location.placemark.coordinate.latitude]
            
            selectedLocation?.name = location.name
            selectedLocation?.number = location.phoneNumber
            selectedLocation?.timeZone = location.timeZone
            selectedLocation?.url = location.url
            
            selectedLocation?.streetNumber = location.placemark.subThoroughfare
            selectedLocation?.streetName = location.placemark.thoroughfare
            selectedLocation?.city = location.placemark.locality
            selectedLocation?.state = location.placemark.administrativeArea
            selectedLocation?.zipCode = location.placemark.postalCode
            selectedLocation?.country = location.placemark.country
            
            selectedLocation?.address = location.placemark.parseAddress()
        }
    }
    
    
    //MARK: - Add Annotation Function
    
    private func addNewAnnotation (_ location: MKMapItem?) {
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.showsUserLocation = false
        
        if let placemark = location?.placemark {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = placemark.coordinate

            if let title = placemark.name, let state = placemark.administrativeArea, let city = placemark.locality {

                annotation.title = title
                annotation.subtitle = "\(city), \(state)"
            }

            //Reaches here if the MKMapItem was intialized by me and not retrieved from the search; likely because the location was preselected
            else if let title = selectedLocation?.name, let state = selectedLocation?.state, let city = selectedLocation?.city {

                annotation.title = title
                annotation.subtitle = "\(city), \(state)"
            }

            shouldSelectAnnotation = true //Fixes bug that caused mapView to annotate back to annotation whenever the region changed
            mapView.addAnnotation(annotation)

            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    //MARK: - Animate and Transition Location Image
    
    private func animateLocationImage (animateIn: Bool, completion: (@escaping () -> Void)) {
        
        if animateIn {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                self.locationSearchView.searchTableView.alpha = 0
                
            } completion: { (finished: Bool) in
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    
                    self.locationSearchView.locationImageContainer.alpha = 1
                }
                
                completion()
            }
        }
        
        else {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                self.locationSearchView.locationImageContainer.alpha = 0
                
            } completion: { (finished: Bool) in
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    
                    self.locationSearchView.searchTableView.alpha = 1
                }
            }
        }
    }
    
    private func transitionLocationImage (maxHeight: CGFloat, searchViewHeight: CGFloat?) {
        
        if let height = searchViewHeight, height >= (maxHeight - 50) {
            
            locationSearchView.locationImageContainer.alpha = 1 - ((1 / 50) * (maxHeight - height))
        }
        
        else {
            
            locationSearchView.locationImageContainer.alpha = 0
        }
    }
}

//MARK: - MKMapViewDelegate Extension

extension AddLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is MKUserLocation {

            return nil
        }

        else {
            
            let annotationIdentifier = "customAnnotationView"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)

            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "customAnnotation.filled")
            
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if let annotation = mapView.annotations.first, annotation is MKUserLocation == false, shouldSelectAnnotation {
            
            mapView.selectAnnotation(annotation, animated: true)
            shouldSelectAnnotation = false
        }
    }
}

//MARK: - CLLocationManagerDelegate Extension

extension AddLocationViewController: CLLocationManagerDelegate {
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        guard let location = locations.last else { return }
//
//            let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//            let region = MKCoordinateRegion(center: center, latitudinalMeters: 10000, longitudinalMeters: 10000)
//            mapView.setRegion(region, animated: true)
//
//            locationManager.stopUpdatingLocation()
//    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        checkLocationServices()
    }
}

//MARK: - TableView DataSource & Delegate Extension

extension AddLocationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if locationMapItem == nil {
            
            return locationSearchResults.count * 2
        }
        
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //If no location has been set yet
        if locationMapItem == nil {
            
            if indexPath.row % 2 == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "locationSearchCell", for: indexPath) as! LocationSearchCell
                cell.selectionStyle = .none
                
                cell.locationNameLabel.text = locationSearchResults[indexPath.row / 2].name
                cell.locationAddressLabel.text = locationSearchResults[indexPath.row / 2].placemark.parseAddress()
                
                return cell
            }
            
            else {
                
                let cell = UITableViewCell()
                cell.backgroundColor = .clear
                cell.isUserInteractionEnabled = false
                return cell
            }
        }
        
        //If a location has been set
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectedLocationCell", for: indexPath) as! SelectedLocationCell
            cell.selectionStyle = .none
            
            cell.locationNameTextField.text = selectedLocation?.name
            cell.locationAddressLabel.text = selectedLocation?.address
            
            cell.locationID = selectedLocation?.locationID
            
            cell.changeLocationNameDelegate = self
            cell.cancelLocationSelectionDelegate = self
            cell.locationSavedDelegate = self
            cell.navigateToLocationDelegate = self
            
            cell.scheduleLabelAnimationWorkItem()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if locationMapItem == nil {
            
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
             
        if locationMapItem == nil {
            
            searchWorkItem?.cancel()
            locationSearch?.cancel()
            
            locationMapItem = locationSearchResults[indexPath.row / 2]
            locationSet(locationMapItem)
            
            locationSearchView.searchTableView.reloadSections([0], with: .fade)
        }
        
        else {
            
            //Brings the selected location's annotation back to the center if the cell is tapped
            if let annotation = mapView.annotations.first {
                
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                
                mapView.setRegion(region, animated: true)
            }
        }
    }
}

//MARK: - ChangeLocationNameProtocol Extension

extension AddLocationViewController: ChangeLocationNameProtocol {
    
    func changesBegan () {
        
        expandView()
    }
    
    func nameChanged (_ name: String?) {
        
        selectedLocation?.name = name
    }
    
    func changesEnded (_ name: String?) {
        
        if let previousAnnotation = mapView.annotations.first {
            
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = previousAnnotation.coordinate
            newAnnotation.title = name
            newAnnotation.subtitle = previousAnnotation.subtitle ?? ""
            
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(newAnnotation)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: newAnnotation.coordinate, span: span)
            
            shouldSelectAnnotation = true //Fixes bug that caused mapView to annotate back to annotation whenever the region changed
            mapView.setRegion(region, animated: true)
            
            sendToSelectedLocationPosition()
        }
    }
}

//MARK: - CancelLocationSelectionProtocol Extension

extension AddLocationViewController: CancelLocationSelectionProtocol {
    
    func selectionCancelled (_ locationID: String?) {

        cancelLocationSelectionDelegate?.selectionCancelled(locationID)
        
        locationMapItem = nil
        selectedLocation = nil
        
        centerViewOnUserLocation()
        
        locationSearchView.searchTableView.reloadSections([0], with: .fade)
        
        if locationSearchView.searchBar?.searchTextField.text?.leniantValidationOfTextEntered() ?? false {
            
            expandView()
        }
        
        else if !(locationSearchView.searchBar?.searchTextField.isFirstResponder ?? false) {
            
            returnToOrigin()
        }
    }
}

//MARK: - LocationSavedProtocol Extension

extension AddLocationViewController: LocationSavedProtocol {
    
    func locationSaved (_ location: Location?) {
        
        locationSavedDelegate?.locationSaved(selectedLocation)
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - NavigateToLocationProtocol Extension

extension AddLocationViewController: NavigateToLocationProtocol {
    
    func navigateToLocation() {
        
        guard let location = locationMapItem else { return }
        
            location.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDefault])
    }
}
