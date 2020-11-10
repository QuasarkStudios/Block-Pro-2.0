//
//  CreateCollabLocationsCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/17/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import MapKit

protocol CreateCollabLocationsCellProtocol: AnyObject {
    
    func attachLocationSelected()
}

class CreateCollabLocationsCell: UITableViewCell {

    let locationsLabel = UILabel()
    let locationCountLabel = UILabel()
    let locationContainer = UIView()
    
    let mapViewContainer = UIView()
    let mapView = MKMapView()
    let cancelButton = UIButton(type: .system)
    let legalButton = UIButton()
    
    let attachLocationButton = UIButton()
    let mapImage = UIImageView(image: UIImage(systemName: "mappin.circle"))
    let attachLocationLabel = UILabel()
    
    let locationPageControl = UIPageControl()
    
    var attachButtonLeadingAnchor: NSLayoutConstraint?
    var attachButtonTrailingAnchor: NSLayoutConstraint?
    var attachButtonTopAnchorWithContainer: NSLayoutConstraint?
    var attachButtonTopAnchorWithMapView: NSLayoutConstraint?
    var attachButtonTopAnchorWithPageControl: NSLayoutConstraint?
    var attachButtonBottomAnchor: NSLayoutConstraint?
    
    var selectedLocations: [Location]? {
        didSet {
            
            reconfigureCell(selectedLocations)
            
            setLocationsCountLabel(selectedLocations)
            
            selectedLocationIndex = selectedLocations != nil && selectedLocations?.count != 0 ? selectedLocations!.count - 1 : 0
        }
    }
    
    var selectedLocationIndex: Int = 0
    
    weak var createCollabLocationsCellDelegate: CreateCollabLocationsCellProtocol?
    weak var locationSelectedDelegate: LocationSelectedProtocol?
    weak var cancelLocationSelectionDelegate: CancelLocationSelectionProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureLocationsLabel()
        configureLocationCountLabel()
        configureLocationContainer()
        configureAttachButton()
        configureGestureRecognizors()
    }
    
    private func reconfigureCell (_ locations: [Location]?) {
        
        if locations?.count ?? 0 == 0 {
            
            configureNoLocationsCell()
        }
        
        else if locations?.count ?? 0 < 3 {
            
            configurePartialLocationsCell()
        }
        
        else {
            
            configureFullLocationsCell()
        }
    }

    private func configureLocationsLabel () {
        
        self.contentView.addSubview(locationsLabel)
        locationsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            locationsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            locationsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            locationsLabel.widthAnchor.constraint(equalToConstant: 75),
            locationsLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        locationsLabel.text = "Locations"
        locationsLabel.textColor = .black
        locationsLabel.textAlignment = .center
        locationsLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
    }
    
    private func configureLocationCountLabel () {
        
        self.contentView.addSubview(locationCountLabel)
        locationCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            locationCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            locationCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            locationCountLabel.widthAnchor.constraint(equalToConstant: 52.5),
            locationCountLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        locationCountLabel.isHidden = true
        locationCountLabel.text = "0/3"
        locationCountLabel.textColor = .black
        locationCountLabel.textAlignment = .right
        locationCountLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
    }
    
    private func configureLocationContainer () {
        
        self.contentView.addSubview(locationContainer)
        locationContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            locationContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            locationContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            locationContainer.topAnchor.constraint(equalTo: locationsLabel.bottomAnchor, constant: 10),
            locationContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
        
        ].forEach({ $0.isActive = true })
        
        locationContainer.backgroundColor = .white
        
        locationContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        locationContainer.layer.borderWidth = 1

        locationContainer.layer.cornerRadius = 10
        locationContainer.layer.cornerCurve = .continuous
        locationContainer.clipsToBounds = true
    }
    
    private func configureMapView () {
        
        if mapViewContainer.superview == nil {
            
            locationContainer.addSubview(mapViewContainer)
            mapViewContainer.addSubview(mapView)
        }
        
        mapViewContainer.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            mapViewContainer.leadingAnchor.constraint(equalTo: locationContainer.leadingAnchor, constant: 10),
            mapViewContainer.trailingAnchor.constraint(equalTo: locationContainer.trailingAnchor, constant: -10),
            mapViewContainer.topAnchor.constraint(equalTo: locationContainer.topAnchor, constant: 10),
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
        
        if let location = selectedLocations?.last {
            
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
    
    private func configureAttachButton () {
        
        locationContainer.addSubview(attachLocationButton)
        attachLocationButton.addSubview(mapImage)
        attachLocationButton.addSubview(attachLocationLabel)
        
        attachLocationButton.translatesAutoresizingMaskIntoConstraints = false
        mapImage.translatesAutoresizingMaskIntoConstraints = false
        attachLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        attachButtonLeadingAnchor = attachLocationButton.leadingAnchor.constraint(equalTo: locationContainer.leadingAnchor, constant: 0)
        attachButtonTrailingAnchor = attachLocationButton.trailingAnchor.constraint(equalTo: locationContainer.trailingAnchor, constant: 0)
        attachButtonTopAnchorWithContainer = attachLocationButton.topAnchor.constraint(equalTo: locationContainer.topAnchor, constant: 0)
        attachButtonTopAnchorWithMapView = attachLocationButton.topAnchor.constraint(equalTo: mapViewContainer.bottomAnchor, constant: 12.5)
        attachButtonTopAnchorWithPageControl = attachLocationButton.topAnchor.constraint(equalTo: locationPageControl.bottomAnchor, constant: 7.5)
        attachButtonBottomAnchor = attachLocationButton.bottomAnchor.constraint(equalTo: locationContainer.bottomAnchor, constant: 0)
        
        attachButtonLeadingAnchor?.isActive = true
        attachButtonTrailingAnchor?.isActive = true
        attachButtonTopAnchorWithContainer?.isActive = true
        attachButtonTopAnchorWithMapView?.isActive = false
        attachButtonTopAnchorWithPageControl?.isActive = false
        attachButtonBottomAnchor?.isActive = true
        
        [

            mapImage.leadingAnchor.constraint(equalTo: attachLocationButton.leadingAnchor, constant: 20),
            mapImage.centerYAnchor.constraint(equalTo: attachLocationButton.centerYAnchor),
            mapImage.widthAnchor.constraint(equalToConstant: 25),
            mapImage.heightAnchor.constraint(equalToConstant: 25),

            attachLocationLabel.leadingAnchor.constraint(equalTo: attachLocationButton.leadingAnchor, constant: 10),
            attachLocationLabel.trailingAnchor.constraint(equalTo: attachLocationButton.trailingAnchor, constant: -10),
            attachLocationLabel.centerYAnchor.constraint(equalTo: attachLocationButton.centerYAnchor),
            attachLocationLabel.heightAnchor.constraint(equalToConstant: 25)

        ].forEach({ $0.isActive = true })
        
        attachLocationButton.backgroundColor = .clear
        attachLocationButton.addTarget(self, action: #selector(attachButtonPressed), for: .touchUpInside)
        
        mapImage.tintColor = .black
        mapImage.isUserInteractionEnabled = false
        
        attachLocationLabel.text = "Attach Locations"
        attachLocationLabel.textColor = .black
        attachLocationLabel.textAlignment = .center
        attachLocationLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        attachLocationLabel.isUserInteractionEnabled = false
    }
    
    private func configureCancelButton () {
        
        if cancelButton.superview == nil {
            
            locationContainer.addSubview(cancelButton)
        }
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            cancelButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 10),
            cancelButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            cancelButton.widthAnchor.constraint(equalToConstant: 25),
            cancelButton.heightAnchor.constraint(equalToConstant: 25),
        
        ].forEach({ $0.isActive = true })
        
        cancelButton.tintColor = UIColor(hexString: "222222")
        
        cancelButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        
        cancelButton.layer.cornerRadius = 25 * 0.5
        cancelButton.clipsToBounds = true
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTouchDown), for: .touchDown)
        cancelButton.addTarget(self, action: #selector(cancelButtonTouchCancelled), for: .touchCancel)
        cancelButton.addTarget(self, action: #selector(cancelButtonTouchCancelled), for: .touchDragExit)
        cancelButton.addTarget(self, action: #selector(cancelButtonTouchUpInside), for: .touchUpInside)
        
        let buttonBackgroundView = UIView(frame: CGRect(x: 5, y: 5, width: 15, height: 15))
        buttonBackgroundView.tag = 1
        buttonBackgroundView.backgroundColor = .white
        buttonBackgroundView.isUserInteractionEnabled = false
        
        buttonBackgroundView.layer.cornerRadius = 15 * 0.5
        buttonBackgroundView.clipsToBounds = true
        
        cancelButton.addSubview(buttonBackgroundView)
        cancelButton.bringSubviewToFront(cancelButton.imageView!)
    }
    
    private func configureLocationPageControl () {
        
        if selectedLocations?.count ?? 0 > 1 {
            
            if locationPageControl.superview == nil {
                
                locationContainer.addSubview(locationPageControl)
            }
            
            locationPageControl.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                locationPageControl.topAnchor.constraint(equalTo: mapViewContainer.bottomAnchor, constant: 7.5),
                locationPageControl.centerXAnchor.constraint(equalTo: locationContainer.centerXAnchor),
                locationPageControl.widthAnchor.constraint(equalToConstant: 125),
                locationPageControl.heightAnchor.constraint(equalToConstant: 27.5)
                
            ].forEach({ $0.isActive = true })
            
            locationPageControl.numberOfPages = selectedLocations?.count ?? 0
            locationPageControl.pageIndicatorTintColor = UIColor(hexString: "D8D8D8")
            locationPageControl.currentPageIndicatorTintColor = UIColor(hexString: "222222")
            locationPageControl.currentPage = selectedLocations?.count != 0 && selectedLocations != nil ? selectedLocations!.count - 1 : 0
            
            locationPageControl.addTarget(self, action: #selector(pageSelected), for: .valueChanged)
        }
        
        else {
            
            locationPageControl.removeFromSuperview()
        }
    }
    
    private func configureGestureRecognizors () {
        
        locationContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mapViewPressed(sender:))))
        
        let mapViewSwipedLeftRecognizor = UISwipeGestureRecognizer(target: self, action: #selector(mapViewSwipedLeft(sender:)))
        mapViewSwipedLeftRecognizor.direction = .left
        locationContainer.addGestureRecognizer(mapViewSwipedLeftRecognizor)
        
        let mapViewSwipedRightRecognizor = UISwipeGestureRecognizer(target: self, action: #selector(mapViewSwipedRight(sender:)))
        mapViewSwipedRightRecognizor.direction = .right
        locationContainer.addGestureRecognizer(mapViewSwipedRightRecognizor)
    }
    
    private func configureNoLocationsCell () {
        
        if attachLocationButton.superview == nil {
            
            self.contentView.addSubview(attachLocationButton)
        }
        
        mapViewContainer.removeFromSuperview()
        cancelButton.removeFromSuperview()
        locationPageControl.removeFromSuperview()
        
        attachButtonTopAnchorWithContainer?.isActive = true
        attachButtonTopAnchorWithMapView?.isActive = false
        attachButtonTopAnchorWithPageControl?.isActive = false
        attachButtonBottomAnchor?.isActive = true
        attachButtonLeadingAnchor?.isActive = true
        attachButtonTrailingAnchor?.isActive = true
        
        attachButtonLeadingAnchor?.constant = 0
        attachButtonTrailingAnchor?.constant = 0
        attachButtonBottomAnchor?.constant = 0
        
        attachLocationButton.backgroundColor = .clear
        attachLocationButton.layer.cornerRadius = 0
        attachLocationButton.clipsToBounds = true
        
        mapImage.tintColor = .black
        
        attachLocationLabel.text = "Attach Locations"
        attachLocationLabel.textColor = .black
        attachLocationLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
    }
    
    private func configurePartialLocationsCell () {
        
        configureMapView()
        
        configureCancelButton()
        
        configureLegalButton()
        
        configureLocationPageControl()
        
        if attachLocationButton.superview == nil {
            
            self.contentView.addSubview(attachLocationButton)
        }
        
        attachButtonTopAnchorWithContainer?.isActive = false
        attachButtonTopAnchorWithMapView?.isActive = selectedLocations?.count ?? 0 == 1
        attachButtonTopAnchorWithPageControl?.isActive = selectedLocations?.count ?? 0 > 1
        attachButtonBottomAnchor?.isActive = true
        attachButtonLeadingAnchor?.isActive = true
        attachButtonTrailingAnchor?.isActive = true
        
        attachButtonBottomAnchor?.constant = -12.5
        attachButtonLeadingAnchor?.constant = 32.5
        attachButtonTrailingAnchor?.constant = -32.5
        
        attachLocationButton.backgroundColor = UIColor(hexString: "222222")
        attachLocationButton.layer.cornerRadius = 20
        attachLocationButton.clipsToBounds = true
        attachLocationButton.addTarget(self, action: #selector(attachButtonPressed), for: .touchUpInside)
        
        mapImage.tintColor = .white
        mapImage.isUserInteractionEnabled = false
        
        attachLocationLabel.text = "Attach"
        attachLocationLabel.textColor = .white
        attachLocationLabel.textAlignment = .center
        attachLocationLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        attachLocationLabel.isUserInteractionEnabled = false
    }
    
    private func configureFullLocationsCell () {
        
        attachLocationButton.removeFromSuperview()
        
        configureMapView()
        
        configureCancelButton()
        
        configureLegalButton()
        
        configureLocationPageControl()
    }
    
    private func setLocationsCountLabel (_ locations: [Location]?) {
        
        if locations?.count ?? 0 == 0 {
            
            locationCountLabel.isHidden = true
        }
        
        else {
            
            locationCountLabel.isHidden = false
            locationCountLabel.text = "\(locations?.count ?? 0)/3"
        }
    }
    
    private func setLocation (_ selectedLocation: Location) {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: selectedLocation.coordinates!["latitude"]!, longitude: selectedLocation.coordinates!["longitude"]!)
        
        annotation.coordinate = coordinate
        annotation.title = selectedLocation.name
        
        if let state = selectedLocation.state, let city = selectedLocation.city {
            
            annotation.subtitle = "\(city), \(state)"
        }
        
        self.mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        self.mapView.setRegion(region, animated: false)
    }
    
    @objc private func attachButtonPressed () {
        
        createCollabLocationsCellDelegate?.attachLocationSelected()
    }
    
    @objc private func mapViewPressed (sender: UITapGestureRecognizer) {
        
        if selectedLocations?.count ?? 0 > 0 {
            
            if mapView.frame.contains(sender.location(in: locationContainer)) {
                
                if let location = selectedLocations?[selectedLocationIndex] {
                    
                    locationSelectedDelegate?.locationSelected(location)
                }
            }
        }
    }
    
    @objc private func mapViewSwipedLeft (sender: UISwipeGestureRecognizer) {
        
        if selectedLocations?.count ?? 0 > 1 {
            
            if mapView.frame.contains(sender.location(in: locationContainer)) {
                
                if selectedLocationIndex != ((selectedLocations?.count ?? 0) - 1) {
                    
                    selectedLocationIndex += 1
                    locationPageControl.currentPage = selectedLocationIndex
                    
                    if let location = selectedLocations?[selectedLocationIndex] {

                        setLocation(location)
                    }
                }
            }
        }
    }
    
    @objc private func mapViewSwipedRight (sender: UISwipeGestureRecognizer) {
        
        if selectedLocations?.count ?? 0 > 1 {
            
            if mapView.frame.contains(sender.location(in: locationContainer)) {
                
                if selectedLocationIndex != 0 {
                    
                    selectedLocationIndex -= 1
                    locationPageControl.currentPage = selectedLocationIndex
                    
                    if let location = selectedLocations?[selectedLocationIndex] {
                        
                        setLocation(location)
                    }
                }
            }
        }
    }
    
    @objc private func cancelButtonTouchDown () {
        
        for subview in cancelButton.subviews {
            
            if subview.tag == 1 {
                
                subview.backgroundColor = .clear
            }
        }
    }
    
    @objc private func cancelButtonTouchCancelled () {
        
        for subview in cancelButton.subviews {
            
            if subview.tag == 1 {
                    
                UIView.animate(withDuration: 0.3) {
                    
                    subview.backgroundColor = .white
                }
            }
        }
    }
    
    @objc private func cancelButtonTouchUpInside () {
        
        for subview in cancelButton.subviews {
            
            if subview.tag == 1 {
                
                UIView.animate(withDuration: 0.3) {
                    
                    subview.backgroundColor = .white
                }
            }
        }
        
        cancelLocationSelectionDelegate?.selectionCancelled(selectedLocations?[selectedLocationIndex].locationID ?? "")
    }
    
    @objc private func legalButtonTapped () {
        
        if let url = URL(string: "https://gspe21-ssl.ls.apple.com/html/attribution-164.html") {
            
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func pageSelected () {
    
        selectedLocationIndex = locationPageControl.currentPage
        
        if let location = selectedLocations?[selectedLocationIndex] {
            
            setLocation(location)
        }
    }
}

extension CreateCollabLocationsCell: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let annotationIdentifier = "customAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)

        if annotationView == nil {

            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "customAnnotation.filled")
            
            DispatchQueue.main.async {

                if let annotation = annotationView?.annotation {

                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        }

        else {

            annotationView?.annotation = annotation
            
            DispatchQueue.main.async {
                
                if let annotation = annotationView?.annotation {
                    
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        }

        return annotationView
    }
}
