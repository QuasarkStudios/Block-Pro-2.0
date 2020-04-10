//
//  previous_nextButton.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/8/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class previous_nextButton: UIButton {

    //Increase the touch area for the previous and next month buttons
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        let newArea = CGRect(x: self.bounds.origin.x - 10, y: self.bounds.origin.y - 10, width: self.bounds.size.width + 15, height: self.bounds.size.height + 15)
        
        return newArea.contains(point)
    }

    
    override init (frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init () {
        self.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
