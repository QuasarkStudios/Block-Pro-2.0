//
//  Public Variables.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/4/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

public var keyWindow = UIApplication.shared.keyWindow

public var topBarHeight: CGFloat {

    let statusBarHeight = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    return statusBarHeight + 44
}
