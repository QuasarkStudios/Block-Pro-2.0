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

public let onboardingMessages: [String] = ["With 2.0, you can organize your tasks into clean and elegant blocks where you’ll be able to attach photos, important locations, voice memos, and links", "You can keep in contact with your friends by sharing messages, photos, and your schedule with them", "And you can create collaborations where you'll have the ability to keep track of the progress of each task and the contributions of everyone involved"]

//General arithmetic used to calculate the size of cells for the photoCollectionView, voiceMemoCollectionView etc.
public let itemSize = floor((UIScreen.main.bounds.width - (40 + 10 + 20)) / 3)

public let minutesToSubtractBy: [Int] = [-5, -10, -15, -30, -45 , -60, -120]
