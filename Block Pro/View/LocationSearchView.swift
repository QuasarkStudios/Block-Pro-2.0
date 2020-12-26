//
//  LocationSearchView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/19/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class LocationSearchView: UIView {
    
    let panGestureIndicator = UIView()
    let panGestureView = UIView()
    
    var searchBar: SearchBar?
    let searchTableView = UITableView()
    
    let locationImageContainer = UIView()
    let locationImageView = UIImageView(image: UIImage(named: "location-search"))
    let locationImageTitle = UILabel()
    
    weak var parentViewController: AnyObject?
    
    init (parentViewController: AnyObject) {
        super.init(frame: .zero)
        
        self.parentViewController = parentViewController
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        
        configureView()
        configurePanGestureIndicator()
        configurePanGestureView()
        configureSearchBar()
        configureLocationImageContainer()
        configureTableView(searchTableView)
    }
    
    private func configureView () {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        guard let view = self.superview, let viewController = parentViewController as? AddLocationViewController else { return }
        
            [
            
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
                self.heightAnchor.constraint(equalToConstant: viewController.locationMapItem != nil ? 265 : 120)
            
            ].forEach({ $0.isActive = true })
            
            self.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            self.layer.cornerRadius = 27.5
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            self.layer.shadowRadius = 2.5
            self.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: -1)
            self.layer.shadowOpacity = 0.25
    }
    
    private func configurePanGestureIndicator () {
        
        self.addSubview(panGestureIndicator)
        panGestureIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            panGestureIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            panGestureIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            panGestureIndicator.widthAnchor.constraint(equalToConstant: 50),
            panGestureIndicator.heightAnchor.constraint(equalToConstant: 7.5)
            
        ].forEach({ $0.isActive = true })
        
        panGestureIndicator.backgroundColor = UIColor(hexString: "222222")
        panGestureIndicator.layer.cornerRadius = 4
        panGestureIndicator.layer.cornerCurve = .continuous
        panGestureIndicator.clipsToBounds = true
    }
    
    private func configurePanGestureView () {
        
        self.addSubview(panGestureView)
        panGestureView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            panGestureView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            panGestureView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            panGestureView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            panGestureView.heightAnchor.constraint(equalToConstant: 120)
        
        ].forEach({ $0.isActive = true })
    }
    
    private func configureSearchBar () {
        
        guard let viewController = parentViewController as? AddLocationViewController else { return }
        
            searchBar = SearchBar(parentViewController: viewController, placeholderText: "Search for places")
        
            self.addSubview(searchBar!)
            searchBar?.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                searchBar?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
                searchBar?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
                searchBar?.topAnchor.constraint(equalTo: panGestureIndicator.bottomAnchor, constant: 15),
                searchBar?.heightAnchor.constraint(equalToConstant: 37)
            
            ].forEach({ $0?.isActive = true })
            
            searchBar?.searchTextField.autocorrectionType = .no
    }
    
    private func configureLocationImageContainer () {
        
        self.addSubview(locationImageContainer)
        locationImageContainer.translatesAutoresizingMaskIntoConstraints = false
        
        locationImageContainer.addSubview(locationImageView)
        locationImageView.translatesAutoresizingMaskIntoConstraints = false
        
        locationImageContainer.addSubview(locationImageTitle)
        locationImageTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let imageViewDimensions = (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? UIScreen.main.bounds.width : UIScreen.main.bounds.width - 20
        
        [
        
            locationImageContainer.topAnchor.constraint(equalTo: searchBar!.bottomAnchor, constant: 0),
            locationImageContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            locationImageContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            locationImageContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            
            locationImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            locationImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -(keyWindow?.safeAreaInsets.bottom ?? 0)),
            locationImageView.widthAnchor.constraint(equalToConstant: imageViewDimensions),
            locationImageView.heightAnchor.constraint(equalToConstant: imageViewDimensions),
            
            locationImageTitle.leadingAnchor.constraint(equalTo: locationImageContainer.leadingAnchor),
            locationImageTitle.trailingAnchor.constraint(equalTo: locationImageContainer.trailingAnchor),
            locationImageTitle.topAnchor.constraint(equalTo: locationImageView.bottomAnchor, constant: 0),
            locationImageTitle.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        locationImageContainer.alpha = 0
        
        locationImageView.contentMode = .scaleAspectFit
        
        locationImageTitle.font = UIFont(name: "Poppins-SemiBold", size: 18)
        locationImageTitle.text = "No Results"
        locationImageTitle.textAlignment = .center
    }
    
    private func configureTableView (_ tableView: UITableView) {
        
        self.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            tableView.topAnchor.constraint(equalTo: searchBar!.bottomAnchor, constant: 15),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
            
        ].forEach({ $0.isActive = true })
        
        if let viewController = parentViewController as? AddLocationViewController {
            
            tableView.dataSource = viewController
            tableView.delegate = viewController
        }
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        tableView.delaysContentTouches = false
        
        tableView.register(LocationSearchCell.self, forCellReuseIdentifier: "locationSearchCell")
        tableView.register(SelectedLocationCell.self, forCellReuseIdentifier: "selectedLocationCell")
    }
}
