//
//  Location+Extension.swift
//  Block Pro
//
//  Created by Nimat Azeez on 11/8/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

extension Location {
    
    func parseAddress () -> String? {
        
        var returnAddress: String = ""
        
        //Street Number
        if let subThoroughfare = self.streetNumber {
            
            returnAddress = subThoroughfare + " "
        }
        
        //Street Name
        if let thoroughFare = self.streetName {
            
            returnAddress += thoroughFare
            returnAddress += ", "
        }
        
        //City
        if let locaility = self.city {
            
            returnAddress += locaility
            returnAddress += ", "
        }
        
        //State
        if let administrativeArea = self.state {
            
            returnAddress += administrativeArea
            returnAddress += " "
        }
        
        //Zip Code
        if let postalAddress = self.zipCode {
            
            returnAddress += postalAddress
        }
        
        return returnAddress.leniantValidationOfTextEntered() ? returnAddress : nil
    }
}
