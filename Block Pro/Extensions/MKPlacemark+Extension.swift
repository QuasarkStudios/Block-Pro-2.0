//
//  MKPlacemark+Extension.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/30/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import MapKit

extension MKPlacemark {
    
    func parseAddress () -> String {
        
        var returnAddress: String = ""
        
        //Street Number
        if let subThoroughfare = self.subThoroughfare {
            
            returnAddress = subThoroughfare + " "
        }
        
        //Street Name
        if let thoroughFare = self.thoroughfare {
            
            returnAddress += thoroughFare
            returnAddress += ", "
        }
        
        //City
        if let locaility = self.locality {
            
            returnAddress += locaility
            returnAddress += ", "
        }
        
        //State
        if let administrativeArea = self.administrativeArea {
            
            returnAddress += administrativeArea
            returnAddress += " "
        }
        
        //Zip Code
        if let postalAddress = self.postalCode {
            
            returnAddress += postalAddress
        }
        
        return returnAddress
    }
}
