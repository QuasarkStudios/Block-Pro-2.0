//
//  CollabProgressProtocol.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/3/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

protocol CollabProgressProtocol: AnyObject {
    
    func filterBlocks (status: BlockStatus?)
    
    func searchBegan ()
    
    func searchTextChanged (searchText: String)
    
    func searchEnded (searchText: String)
}
