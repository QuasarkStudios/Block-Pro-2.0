//
//  LocationProtocols.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/26/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation
import MapKit

protocol ChangeLocationNameProtocol: AnyObject {
    
    func changesBegan ()
    
    func nameChanged (_ name: String?)
    
    func changesEnded (_ name: String?)
}

protocol CancelLocationSelectionProtocol: AnyObject {
    
    func selectionCancelled (_ locationID: String?)
}

protocol NavigateToLocationProtocol: AnyObject {
    
    func navigateToLocation ()
}

protocol LocationSavedProtocol: AnyObject {
    
    func locationSaved (_ location: Location?)
}

protocol LocationSelectedProtocol: AnyObject {
    
    func locationSelected (_ location: Location?)
}
