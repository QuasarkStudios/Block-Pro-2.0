//
//  WeekHeaderCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/2/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class WeekHeaderCell: UITableViewCell {

    @IBOutlet weak var weekRangeLabel: UILabel!
    
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    
    var homeViewController: HomeViewController?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func leftButton(_ sender: Any) {
        
//        //let homeViewController = HomeViewController()
//        
//        let homeCellIndexPath: IndexPath = IndexPath(row: 1, section: indexPath!.section)
//        let collectionViewIndexPath: IndexPath = IndexPath(row: 0, section: 0)
//        
//        homeViewController!.testFunc(cell: homeViewController!.tableView(homeViewController!.homeTableView, cellForRowAt: homeCellIndexPath), indexPath: collectionViewIndexPath)
//        
//        //print(homeViewController.homeTableView.visibleCells)
        
    }
    
    
    @IBAction func rightButton(_ sender: Any) {
        
        print("coolio")
    }
    
}
