//
//  SelectedLocationProtocols.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/26/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

protocol NavigateToLocationProtocol: AnyObject {
    
    func navigateToLocation ()
}

protocol CancelLocationSelectionProtocol: AnyObject {
    
    func selectionCancelled ()
}
