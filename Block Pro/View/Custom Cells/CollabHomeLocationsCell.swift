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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationPageControl: UIPageControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mapView.layer.cornerRadius = 15
        mapView.clipsToBounds = true
        
        locationPageControl.pageIndicatorTintColor = UIColor(hexString: "D8D8D8")
        locationPageControl.currentPageIndicatorTintColor = UIColor(hexString: "222222")
    }
}
