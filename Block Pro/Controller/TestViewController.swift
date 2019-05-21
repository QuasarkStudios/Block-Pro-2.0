//
//  TestViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/19/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import RealmSwift

class TestViewController: UIViewController {

    let realm = try! Realm() //Initializing a new "Realm"
    
    var testBlock: Results<Block>?
    
    //let testBlock = Block()
    
    @IBOutlet weak var testInput: UITextField!
    @IBOutlet weak var testLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func testButton(_ sender: Any) {

        
        
        
        //Updating a model
//        testBlock = realm.objects(Block.self)
//
//        do {
//            try self.realm.write {
//                self.testBlock![0].name = testInput.text!
//            }
//        } catch {
//            print ("Error updating block \(error)")
//
//        }
    }
    
    
    
    
}
    

