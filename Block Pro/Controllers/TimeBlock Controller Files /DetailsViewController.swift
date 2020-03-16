//
//  DetailsViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/13/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var detailsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailsTableView.dataSource = self
        detailsTableView.delegate = self
        
        detailsTableView.rowHeight = 400
        
        detailsTableView.register(UINib(nibName: "ProgressCirclesCell", bundle: nil), forCellReuseIdentifier: "progressCirclesCell")
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "progressCirclesCell", for: indexPath) as! ProgressCirclesCell
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    
}
