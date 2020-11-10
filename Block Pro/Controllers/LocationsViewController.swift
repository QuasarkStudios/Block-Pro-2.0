//
//  LocationsViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 11/6/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import MapKit

class LocationsViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    
    let mapView = MKMapView()
    
    let locationInfoView = UIView()
    let locationNameLabel = UILabel()
    var nameLabelTopAnchor: NSLayoutConstraint?
    var nameLabelHeightConstraint: NSLayoutConstraint?
    
    let locationAddressLabel = UILabel()
    
    let locationPageControl = UIPageControl()
    
    let navigateButton = UIButton(type: .system)
    let phoneButton = UIButton(type: .system)
    let urlButton = UIButton(type: .system)
    
    var urlButtonTopAnchorToNavigateButton: NSLayoutConstraint?
    var urlButtonTopAnchorToPhoneButton: NSLayoutConstraint?
    
    var locations: [Location]?
    
    var selectedLocationIndex: Int = 0
    
    var shouldSelectAnnotation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: -15, right: 0)
        
        navBar.configureNavBar(barBackgroundColor: UIColor.white.withAlphaComponent(0.9))
        
        configureMapView ()
        
        self.view.bringSubviewToFront(navBar) //Call this after configureMapView()
        
        configureLocationInfoView()
        configureLocationNameLabel()
        configureLocationAddressLabel()
        configureLocationPageControl()
        configureGestureRecognizors()
        
        configureNavigateButton()
        configurePhoneButton()
        configureURLButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        addAnnotation()
    }
    
    
    //MARK: - Configuration Functions
    
    private func configureMapView () {
        
        self.view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        mapView.delegate = self
    }
    
    private func configureLocationInfoView () {
        
        self.view.addSubview(locationInfoView)
        locationInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomAnchor = (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? -((UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + 15) : -22.5
        
        [
        
            locationInfoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            locationInfoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            locationInfoView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: bottomAnchor),
            locationInfoView.heightAnchor.constraint(equalToConstant: locations?.count ?? 0 < 2 ? 90 : 95)
        
        ].forEach({ $0.isActive = true })
        
        locationInfoView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        locationInfoView.layer.cornerRadius = locations?.count ?? 0 < 2 ? 45 : 47.5
        
        locationInfoView.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        locationInfoView.layer.shadowOpacity = 0.25
        locationInfoView.layer.shadowRadius = 2.5
        locationInfoView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    private func configureLocationNameLabel () {
        
        locationInfoView.addSubview(locationNameLabel)
        locationNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        locationNameLabel.leadingAnchor.constraint(equalTo: locationInfoView.leadingAnchor, constant: 25).isActive = true
        locationNameLabel.trailingAnchor.constraint(equalTo: locationInfoView.trailingAnchor, constant: -25).isActive = true
        
        nameLabelTopAnchor = locationNameLabel.topAnchor.constraint(equalTo: locationInfoView.topAnchor, constant: 0)
        nameLabelTopAnchor?.isActive = true
        
        nameLabelHeightConstraint = locationNameLabel.heightAnchor.constraint(equalToConstant: 0)
        nameLabelHeightConstraint?.isActive = true
        
        locationNameLabel.font = UIFont(name: "Poppins-SemiBold", size: 20)
        locationNameLabel.textColor = .black
        
        setLocationName() //Handles setting the topAnchor and height constraint
    }
    
    private func configureLocationAddressLabel () {
        
        locationInfoView.addSubview(locationAddressLabel)
        locationAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            locationAddressLabel.leadingAnchor.constraint(equalTo: locationInfoView.leadingAnchor, constant: 26),
            locationAddressLabel.trailingAnchor.constraint(equalTo: locationInfoView.trailingAnchor, constant: -26),
            locationAddressLabel.topAnchor.constraint(equalTo: locationNameLabel.bottomAnchor),
        
        ].forEach({ $0.isActive = true })
        
        locationAddressLabel.font = UIFont(name: "Poppins-Italic", size: 13)
        locationAddressLabel.textColor = .lightGray
        
        setLocationAddress() //Handles setting the height constraint
    }
    
    private func configureLocationPageControl () {
            
        if locations?.count ?? 0 < 2 {
            return
        }
        
        locationInfoView.addSubview(locationPageControl)
        locationPageControl.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            locationPageControl.bottomAnchor.constraint(equalTo: locationInfoView.bottomAnchor, constant: -1),
            locationPageControl.centerXAnchor.constraint(equalTo: locationInfoView.centerXAnchor),
            locationPageControl.widthAnchor.constraint(equalToConstant: 125),
            locationPageControl.heightAnchor.constraint(equalToConstant: 27.5)
            
        ].forEach({ $0.isActive = true })
        
        locationPageControl.numberOfPages = locations?.count ?? 0
        locationPageControl.pageIndicatorTintColor = UIColor(hexString: "D8D8D8")
        locationPageControl.currentPageIndicatorTintColor = UIColor(hexString: "222222")
        locationPageControl.currentPage = selectedLocationIndex
        
        locationPageControl.addTarget(self, action: #selector(pageSelected), for: .valueChanged)
    }
    
    private func configureNavigateButton () {
        
        self.view.addSubview(navigateButton)
        navigateButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            navigateButton.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 25),
            navigateButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            navigateButton.widthAnchor.constraint(equalToConstant: 45),
            navigateButton.heightAnchor.constraint(equalToConstant: 45)
            
        ].forEach({ $0.isActive = true })
        
        navigateButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        navigateButton.tintColor = .black
        navigateButton.setImage(UIImage(systemName: "location.fill.viewfinder"), for: .normal)
        
        navigateButton.layer.cornerRadius = 45 * 0.5
        
        navigateButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        navigateButton.layer.shadowOpacity = 0.25
        navigateButton.layer.shadowRadius = 2.5
        navigateButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        navigateButton.addTarget(self, action: #selector(navigateButtonTapped), for: .touchUpInside)
    }
    
    private func configurePhoneButton () {
        
        if locations?[selectedLocationIndex].number != nil {
            
            self.view.addSubview(phoneButton)
            phoneButton.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                phoneButton.topAnchor.constraint(equalTo: navigateButton.bottomAnchor, constant: 12.5),
                phoneButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                phoneButton.widthAnchor.constraint(equalToConstant: 45),
                phoneButton.heightAnchor.constraint(equalToConstant: 45)
                
            ].forEach({ $0.isActive = true })
            
            phoneButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            phoneButton.tintColor = .black
            phoneButton.setImage(UIImage(systemName: "phone.fill"), for: .normal)
            
            phoneButton.layer.cornerRadius = 45 * 0.5
            
            phoneButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
            phoneButton.layer.shadowOpacity = 0.25
            phoneButton.layer.shadowRadius = 2.5
            phoneButton.layer.shadowOffset = CGSize(width: 0, height: 0)
            
            phoneButton.addTarget(self, action: #selector(phoneButtonTapped), for: .touchUpInside)
            
            if phoneButton.alpha == 0 {
                
                UIView.animate(withDuration: 0.3) {
                    
                    self.phoneButton.alpha = 1
                }
            }
        }
        
        else {
            
            UIView.animate(withDuration: 0.3) {
                
                self.phoneButton.alpha = 0
                
            } completion: { (finished: Bool) in
                
                self.phoneButton.removeFromSuperview()
            }
        }
    }
    
    private func configureURLButton () {
        
        if locations?[selectedLocationIndex].url != nil {
            
            self.view.addSubview(urlButton)
            urlButton.translatesAutoresizingMaskIntoConstraints = false
            
            urlButtonTopAnchorToNavigateButton?.isActive = false
            urlButtonTopAnchorToPhoneButton?.isActive = false
            
            if locations?[selectedLocationIndex].number != nil {
                
                urlButtonTopAnchorToPhoneButton = urlButton.topAnchor.constraint(equalTo: phoneButton.bottomAnchor, constant: 12.5)
                urlButtonTopAnchorToPhoneButton?.isActive = true
            }
            
            else {
                
                urlButtonTopAnchorToNavigateButton = urlButton.topAnchor.constraint(equalTo: navigateButton.bottomAnchor, constant: 12.5)
                urlButtonTopAnchorToNavigateButton?.isActive = true
            }
            
            [
            
                urlButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                urlButton.widthAnchor.constraint(equalToConstant: 45),
                urlButton.heightAnchor.constraint(equalToConstant: 45)
                
            ].forEach({ $0.isActive = true })
            
            urlButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            urlButton.tintColor = .black
            urlButton.setImage(UIImage(systemName: "link"), for: .normal)
            
            urlButton.layer.cornerRadius = 45 * 0.5
            
            urlButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
            urlButton.layer.shadowOpacity = 0.25
            urlButton.layer.shadowRadius = 2.5
            urlButton.layer.shadowOffset = CGSize(width: 0, height: 0)
            
            urlButton.addTarget(self, action: #selector(urlButtonTapped), for: .touchUpInside)
            
            if urlButton.alpha == 0 {
                
                UIView.animate(withDuration: 0.3) {
                    
                    self.urlButton.alpha = 1
                }
            }
        }
        
        else {
            
            UIView.animate(withDuration: 0.3) {
                
                self.urlButton.alpha = 0
                
            } completion: { (finished: Bool) in
                
                self.urlButton.removeFromSuperview()
            }
        }
    }
    
    private func configureGestureRecognizors () {
        
        locationInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationViewTapped)))
        
        let locationViewSwipedLeftRecognizor = UISwipeGestureRecognizer(target: self, action: #selector(locationViewSwipedLeft))
        locationViewSwipedLeftRecognizor.direction = .left
        locationInfoView.addGestureRecognizer(locationViewSwipedLeftRecognizor)
        
        let locationViewSwipedRightRecognizor = UISwipeGestureRecognizer(target: self, action: #selector(locationViewSwipedRight))
        locationViewSwipedRightRecognizor.direction = .right
        locationInfoView.addGestureRecognizer(locationViewSwipedRightRecognizor)
    }
    
    
    //MARK: - Add Annotation
    
    private func addAnnotation () {
        
        mapView.removeAnnotations(mapView.annotations)
        
        if let location = locations?[selectedLocationIndex], let latitude = location.coordinates?["latitude"], let longitude = location.coordinates?["longitude"] {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            annotation.title = location.name ?? "Location #\(selectedLocationIndex + 1)"
            
            if let city = location.city, let state = location.state {
                
                annotation.subtitle = "\(city), \(state)"
            }
            
            shouldSelectAnnotation = true
            mapView.addAnnotation(annotation)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    //MARK: - Set Location Name
    
    private func setLocationName () {
        
        nameLabelTopAnchor?.constant = locations?[selectedLocationIndex].address != nil ? 20 : 0
        
        if locations?[selectedLocationIndex].address != nil {
            
            nameLabelHeightConstraint?.constant = 30
        }
        
        else {
            
            nameLabelHeightConstraint?.constant = locations?.count ?? 0 < 2 ? 90 : 95
        }
        
        locationNameLabel.textAlignment = locations?[selectedLocationIndex].address != nil ? .left : .center
        
        if let name = locations?[selectedLocationIndex].name {
            
            locationNameLabel.text = name
        }
        
        else {
            
            locationNameLabel.text = "Location #\(selectedLocationIndex + 1)"
        }
    }
    
    
    //MARK: - Set Location Address
    
    private func setLocationAddress () {
        
        let addressLabelHeightConstraint = locationAddressLabel.constraints.first(where: { $0.firstAttribute == .height })
        addressLabelHeightConstraint?.constant = locations?[selectedLocationIndex].address != nil ? 20 : 0
        
        locationAddressLabel.text = locations?[selectedLocationIndex].address
    }
    
    
    //MARK: - Button Functions
    
    @objc private func navigateButtonTapped () {
        
        if let annotation = mapView.annotations.first {
            
            let location = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate))
            location.name = locations?[selectedLocationIndex].name ?? "Location #\(selectedLocationIndex + 1)"
            location.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDefault])
        }
    }
    
    @objc private func phoneButtonTapped () {
        
        if let number = locations?[selectedLocationIndex].number?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: ""), let url = URL(string: "tel://" + number) {

            UIApplication.shared.open(url)
        }
    }
    
    @objc private func urlButtonTapped () {
        
        if let url = locations?[selectedLocationIndex].url {
            
            UIApplication.shared.open(url)
        }
    }
    
    
    //MARK: - Location View Gesture Functions
    
    @objc private func locationViewTapped () {
        
        //Brings the selected location's annotation back to the center if the view is tapped
        if let annotation = mapView.annotations.first {
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
            
            shouldSelectAnnotation = true
            mapView.setRegion(region, animated: true)
        }
    }
    
    @objc private func locationViewSwipedLeft () {
        
        if locations?.count ?? 0 > 1 {
            
            if selectedLocationIndex != ((locations?.count ?? 0) - 1) {
                
                selectedLocationIndex += 1
                locationPageControl.currentPage = selectedLocationIndex

                addAnnotation()
                setLocationName()
                setLocationAddress()
                
                configurePhoneButton()
                configureURLButton()
            }
        }
    }
    
    @objc private func locationViewSwipedRight () {
        
        if locations?.count ?? 0 > 1 {
            
            if selectedLocationIndex != 0 {
                
                selectedLocationIndex -= 1
                locationPageControl.currentPage = selectedLocationIndex
                    
                addAnnotation()
                setLocationName()
                setLocationAddress()
                
                configurePhoneButton()
                configureURLButton()
            }
        }
    }
    
    
    //MARK: - Page Control Function
    
    @objc private func pageSelected () {
    
        selectedLocationIndex = locationPageControl.currentPage
        addAnnotation()

        setLocationName()
        setLocationAddress()
        
        configurePhoneButton()
        configureURLButton()
    }
    
    @IBAction func exitButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - MKMapViewDelegate Extension

extension LocationsViewController: MKMapViewDelegate {
    
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
