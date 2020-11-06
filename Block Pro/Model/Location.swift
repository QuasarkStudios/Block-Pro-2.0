//
//  Location.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/30/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
import MapKit

struct Location {
    
    var locationID: String?
    
    var coordinates: [String : Double]?
    
    var name: String?
    
    var placemark: MKPlacemark?
    
    var address: String?
    
    var streetNumber: String?
    var streetName: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var country: String?
    
    var number: String?
    var timeZone: TimeZone?
    var url: URL?
}
