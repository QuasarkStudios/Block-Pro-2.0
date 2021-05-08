//
//  RegistrationProtocols.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/1/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

protocol NameRegistration: AnyObject {
    
    func firstNameEntered (firstName: String)
    
    func lastNameEntered (lastName: String)
}

protocol EmailAddressRegistration: AnyObject {
    
    func emailAddressEntered (email: String)
}

protocol UsernameRegistration: AnyObject {
    
    func usernameEntered (username: String)
}

protocol PasswordRegistration: AnyObject {
    
    func passwordEntered (password: String)
}

protocol ProfilePictureRegistration: AnyObject {
    
    func addProfilePicture ()
    
    func skipProfilePicture ()
}
