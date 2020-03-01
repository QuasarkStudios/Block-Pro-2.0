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
    @IBOutlet weak var gradientView: UIView!
    
    let personalDatabase = PersonalRealmDatabase()
    
    var currentDateObject: TimeBlocksDate?
    var currentDate: Date? {
        didSet {
            
            currentDateObject = personalDatabase.findTimeBlocks(currentDate!)
        }
    }
    
    
    let formatter = DateFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        formatter.dateFormat = "EEEE, MMMM d"
        navigationItem.title =  formatter.string(from: currentDate!)
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 20)!]
        
        timeBlockTableView.dataSource = self
        timeBlockTableView.delegate = self
        timeBlockTableView.rowHeight = 2210//1490
        timeBlockTableView.separatorStyle = .none
        timeBlockTableView.showsVerticalScrollIndicator = false

        timeBlockTableView.register(UINib(nibName: "TimeBlockCell", bundle: nil), forCellReuseIdentifier: "timeBlockCell")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        applyGradientFade()
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
        
        cell.personalDatabase = personalDatabase
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //print("selected row")
    }
    
    private func applyGradientFade () {
        
        let gradientFade = CAGradientLayer()
        gradientFade.frame = gradientView.bounds
        gradientFade.colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0.75).cgColor, UIColor.clear.cgColor]
        gradientFade.locations = [0.25, 0.5, 0.9]
        
        gradientView.layer.mask = gradientFade
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToAddEditView" {
            
            let addEditVC = segue.destination as! AddEditBlockViewController
            addEditVC.currentDateObject = currentDateObject!
            addEditVC.currentDate = currentDate!
        }
        
    }
    
}
