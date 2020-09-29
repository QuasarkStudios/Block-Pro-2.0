//
//  CachePhotoProtocol.swift
//  Block Pro
//
//  Created by Nimat Azeez on 9/9/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

protocol CachePhotoProtocol: AnyObject {
    
    func cachePhoto (messageID: String, photo: UIImage?)
}
