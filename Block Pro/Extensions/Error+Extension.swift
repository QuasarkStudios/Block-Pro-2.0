//
//  Error+Extension.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/28/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

extension Error {
    
    //Determines if the photo retrieval should be tried again
    func retryStorageRetrieval () -> Bool {
        
        let firebaseStorage = FirebaseStorage()
        
        //Gets the error code
        if let error = self as NSError?, let errorCode = firebaseStorage.getStorageErrorCode(error) {
            
            switch errorCode {
            
            //Possible caused because the photo hasn't finished uploading
            case .objectNotFound:
                
                return true
                
            default:
                
                return false
            }
        }
        
        else {
            
            return false
        }
    }
}
