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

    let statusBarHeight = keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    return statusBarHeight + 44
}

//URL for the user's document directory
public var documentsDirectory: URL {
    
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

//General arithmetic used to calculate the size of cells for the photoCollectionView, voiceMemoCollectionView etc.
public let itemSize = floor((UIScreen.main.bounds.width - (40 + 10 + 20)) / 3)
