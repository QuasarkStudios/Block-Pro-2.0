//
//  TimeBlockViewController2.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import ChameleonFramework


class TimeBlockViewController2: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var timeBlockTableView: UITableView!
    
    
    var currentDate: Date = Date()
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        formatter.dateFormat = "EEEE, MMMM d"
        navigationItem.title =  formatter.string(from: currentDate)
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 20)!]
        
        timeBlockTableView.dataSource = self
        timeBlockTableView.delegate = self
        timeBlockTableView.rowHeight = 1490//2880
        timeBlockTableView.separatorStyle = .none

        timeBlockTableView.register(UINib(nibName: "TimeBlockCell", bundle: nil), forCellReuseIdentifier: "timeBlockCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        UIView.animate(withDuration: 0.5) {
//
//            self.timeBlockTableView.contentOffset = CGPoint(x: 0, y: 1000)
//        }
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "timeBlockCell", for: indexPath) as! TimeBlockCell
//        cell.textLabel!.text = "New Day"
        cell.selectionStyle = .none
        
        return cell
        
    }
    
}
