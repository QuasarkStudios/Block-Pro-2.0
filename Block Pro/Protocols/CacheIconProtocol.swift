//
//  CacheIconProtocol.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/13/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

protocol CacheIconProtocol: AnyObject {
    
    func cacheIcon (linkID: String, icon: UIImage?)
}
