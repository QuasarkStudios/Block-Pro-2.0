//
//  CollabBlockPopoverViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 8/1/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabBlockPopoverViewController: UIViewController {

    @IBOutlet weak var exitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func exitButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    

}
