//
//  CollabBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/10/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabBlockViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var blockTableView: UITableView!
    @IBOutlet weak var verticalTableSeperator: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timeTableView.delegate = self
        timeTableView.dataSource = self
        
        timeTableView.showsVerticalScrollIndicator = false
        timeTableView.allowsSelection = false
        timeTableView.separatorStyle = .none
        timeTableView.rowHeight = 120.0
        
        blockTableView.delegate = self
        blockTableView.dataSource = self
        blockTableView.separatorStyle = .none
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if tableView == timeTableView {
            cell.textLabel!.text = "Some Time"
        }
        
        else {
            cell.textLabel!.text = "Some Block"
        }
        
        return cell
        
    }
}
