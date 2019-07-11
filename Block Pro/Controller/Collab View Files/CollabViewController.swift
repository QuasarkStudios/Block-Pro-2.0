//
//  CollabViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/7/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var friendsButton: UIBarButtonItem!
    @IBOutlet weak var createCollabButton: UIBarButtonItem!
    
    @IBOutlet weak var upcomingCollabTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        upcomingCollabTableView.delegate = self
        upcomingCollabTableView.dataSource = self
        
        upcomingCollabTableView.register(UINib(nibName: "UpcomingCollabTableCell", bundle: nil), forCellReuseIdentifier: "UpcomingCollabCell")
        
        upcomingCollabTableView.rowHeight = 105
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Jan. 1 2019"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCollabCell", for: indexPath) as! UpcomingCollabTableCell
        
        if indexPath.row == 1 {
            cell.collabNameLabel.text = "Beach Day "
        }
        else {
           cell.collabNameLabel.text = "Do Homework "
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "moveToCollabBlockView", sender: self)
    }


}
