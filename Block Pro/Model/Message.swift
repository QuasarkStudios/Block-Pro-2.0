//
//  Message.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/28/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

struct Message {
    
    var messageID: String = ""
    
    var sender: String = ""
    
    var message: String?
    
    var messagePhoto: [String : Any]?
    
//    var photoID: String?
//    var photo: UIImage? = nil
//    var photoWidth: CGFloat?
//    var photoHeight: CGFloat?
    
    var timestamp: Date!
}
