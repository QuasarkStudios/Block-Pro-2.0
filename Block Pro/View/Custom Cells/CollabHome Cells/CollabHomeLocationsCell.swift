//
//  CollabHomeLocationsCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/11/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import MapKit

class CollabHomeLocationsCell: UITableViewCell {
    
    lazy var locationContainer = UIView()
    
    lazy var mapViewContainer = UIView()
    lazy var mapView = MKMapView()
    lazy var legalButton = UIButton()
    
    lazy var locationPageControl = UIPageControl()
    
    lazy var noLocationsImageView = UIImageView(image: UIImage(named: "no-locations"))
    lazy var noLocationsLabel = UILabel()
    
    var locations: [Location]? {
        didSet {
            
            reconfigureCell(locations)
        }
    }
    
    var selectedLocationIndex = 0
    
    weak var locationSelectedDelegate: LocationSelectedProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureGestureRecognizors()
    }
    
    private func reconfigureCell (_ locations: [Location]?) {
        
        if locations?.count ?? 0 == 0 {
            
            configureNoLocationsCell()
        }
        
        else {
            
            locationContainer.removeFromSuperview()
            
            configureMapView()
            configureLegalButton()
            configureLocationPageControl()
        }
    }
    
    private func configureMapView () {
        
        if mapViewContainer.superview == nil {
            
            contentView.addSubview(mapViewContainer)
            mapViewContainer.addSubview(mapView)
        }
        
        mapViewContainer.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            mapViewContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            mapViewContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            mapViewContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            mapViewContainer.heightAnchor.constraint(equalToConstant: 180),
            
            mapView.leadingAnchor.constraint(equalTo: mapViewContainer.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: mapViewContainer.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: mapViewContainer.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: mapViewContainer.bottomAnchor)
        
        ].forEach({ $0.isActive = true })
        
        mapViewContainer.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        mapViewContainer.layer.shadowOpacity = 0.3
        mapViewContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        mapViewContainer.layer.shadowRadius = 2.5
        
        mapViewContainer.layer.cornerRadius = 15
        mapViewContainer.clipsToBounds = false
        
        mapView.delegate = self
        
        mapView.isUserInteractionEnabled = false
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        
        mapView.layer.cornerRadius = 15
        mapView.clipsToBounds = true
        
        if let location = locations?.first {
            
            setLocation(location)
        }
    }
    
    private func configureLegalButton () {
        
        mapViewContainer.addSubview(legalButton)
        legalButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            legalButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -5),
            legalButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 0),
            legalButton.widthAnchor.constraint(equalToConstant: 42.5),
            legalButton.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        legalButton.addTarget(self, action: #selector(legalButtonTapped), for: .touchUpInside)
    }
    
    private func configureLocationPageControl () {
        
        if locations?.count ?? 0 > 1 {
            
            if locationPageControl.superview == nil {
                
                contentView.addSubview(locationPageControl)
            }
            
            locationPageControl.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                locationPageControl.topAnchor.constraint(equalTo: mapViewContainer.bottomAnchor, constant: 7.5),
                locationPageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                locationPageControl.widthAnchor.constraint(equalToConstant: 125),
                locationPageControl.heightAnchor.constraint(equalToConstant: 27.5)
                
            ].forEach({ $0.isActive = true })
            
            locationPageControl.numberOfPages = locations?.count ?? 0
            locationPageControl.pageIndicatorTintColor = UIColor(hexString: "D8D8D8")
            locationPageControl.currentPageIndicatorTintColor = UIColor(hexString: "222222")
            
            locationPageControl.addTarget(self, action: #selector(pageSelected), for: .valueChanged)
        }
        
        else {
            
            locationPageControl.removeFromSuperview()
        }
    }
    
    private func configureGestureRecognizors () {
        
        mapViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mapViewPressed(sender:))))
        
        let mapViewSwipedLeftRecognizor = UISwipeGestureRecognizer(target: self, action: #selector(mapViewSwipedLeft(sender:)))
        mapViewSwipedLeftRecognizor.direction = .left
        mapViewContainer.addGestureRecognizer(mapViewSwipedLeftRecognizor)
        
        let mapViewSwipedRightRecognizor = UISwipeGestureRecognizer(target: self, action: #selector(mapViewSwipedRight(sender:)))
        mapViewSwipedRightRecognizor.direction = .right
        mapViewContainer.addGestureRecognizer(mapViewSwipedRightRecognizor)
    }
    
    private func configureNoLocationsCell () {
        
        mapViewContainer.removeFromSuperview()
        locationContainer.removeFromSuperview()
        
        self.contentView.addSubview(locationContainer)
        locationContainer.addSubview(noLocationsImageView)
        locationContainer.addSubview(noLocationsLabel)
        
        locationContainer.translatesAutoresizingMaskIntoConstraints = false
        noLocationsImageView.translatesAutoresizingMaskIntoConstraints = false
        noLocationsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            locationContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            locationContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            locationContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            locationContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
            
            noLocationsImageView.leadingAnchor.constraint(equalTo: locationContainer.leadingAnchor, constant: 0),
            noLocationsImageView.trailingAnchor.constraint(equalTo: locationContainer.trailingAnchor, constant: 0),
            noLocationsImageView.topAnchor.constraint(equalTo: locationContainer.topAnchor, constant: 10),
            noLocationsImageView.bottomAnchor.constraint(equalTo: noLocationsLabel.topAnchor, constant: -12),
            
            noLocationsLabel.leadingAnchor.constraint(equalTo: locationContainer.leadingAnchor, constant: 0),
            noLocationsLabel.trailingAnchor.constraint(equalTo: locationContainer.trailingAnchor, constant: 0),
            noLocationsLabel.bottomAnchor.constraint(equalTo: locationContainer.bottomAnchor, constant: -12),
            noLocationsLabel.heightAnchor.constraint(equalToConstant: 15)
            
        ].forEach({ $0.isActive = true })
        
        locationContainer.backgroundColor = .white
        
        locationContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        locationContainer.layer.borderWidth = 1

        locationContainer.layer.cornerRadius = 10
        locationContainer.layer.cornerCurve = .continuous
        locationContainer.clipsToBounds = true
        
        noLocationsImageView.contentMode = .scaleAspectFit
        
        noLocationsLabel.text = "No Locations Yet"
        noLocationsLabel.textColor = UIColor(hexString: "222222")
        noLocationsLabel.textAlignment = .center
        noLocationsLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
    }
    
    private func setLocation (_ location: Location) {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinates!["latitude"]!, longitude: location.coordinates!["longitude"]!)
        
        annotation.coordinate = coordinate
        annotation.title = location.name ?? "Location #\(selectedLocationIndex + 1)"
        
        if let state = location.state, let city = location.city {
            
            annotation.subtitle = "\(city), \(state)"
        }
        
        self.mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        self.mapView.setRegion(region, animated: false)
    }
    
    @objc private func mapViewPressed (sender: UITapGestureRecognizer) {
        
        if locations?.count ?? 0 > 0 {
            
            if let location = locations?[selectedLocationIndex] {
                
                locationSelectedDelegate?.locationSelected(location)
            }
        }
    }
    
    @objc private func mapViewSwipedLeft (sender: UISwipeGestureRecognizer) {
        
        if locations?.count ?? 0 > 1 {
            
            if selectedLocationIndex != ((locations?.count ?? 0) - 1) {
                
                selectedLocationIndex += 1
                locationPageControl.currentPage = selectedLocationIndex
                
                if let location = locations?[selectedLocationIndex] {

                    setLocation(location)
                }
            }
        }
    }
    
    @objc private func mapViewSwipedRight (sender: UISwipeGestureRecognizer) {
        
        if locations?.count ?? 0 > 1 {
            
            if selectedLocationIndex != 0 {
                
                selectedLocationIndex -= 1
                locationPageControl.currentPage = selectedLocationIndex
                
                if let location = locations?[selectedLocationIndex] {
                    
                    setLocation(location)
                }
            }
        }
    }
    
    @objc private func legalButtonTapped () {
        
        if let url = URL(string: "https://gspe21-ssl.ls.apple.com/html/attribution-164.html") {
            
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func pageSelected () {
    
        selectedLocationIndex = locationPageControl.currentPage
        
        if let location = locations?[selectedLocationIndex] {
            
            setLocation(location)
        }
    }
}

extension CollabHomeLocationsCell: MKMapViewDelegate {
    
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
        
        if let annotation = mapView.annotations.first, annotation is MKUserLocation == false {
            
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
}
