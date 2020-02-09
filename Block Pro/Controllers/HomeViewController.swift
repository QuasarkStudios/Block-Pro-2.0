//
//  HomeViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/29/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var faceImage: UIImageView!
    
    @IBOutlet weak var selectionIndicator: SelectionIndicator!
    
    @IBOutlet weak var homeTableView: UITableView!
    
    @IBOutlet weak var monthButton: UIButton!
    
    let formatter = DateFormatter()
    
    var weekSectionArray: [[Date]] = [[]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        formatter.dateFormat = "MMMM"
        navigationItem.title = formatter.string(from: Date())
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 25)!]
        
        faceImage.layer.cornerRadius = 0.5 * faceImage.bounds.width
        faceImage.clipsToBounds = true
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        homeTableView.showsVerticalScrollIndicator = false
        homeTableView.separatorStyle = .none
        //homeTableView.rowHeight = 430
        
        homeTableView.register(UINib(nibName: "WeekHeaderCell", bundle: nil), forCellReuseIdentifier: "weekHeaderCell")
        homeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeCell")
        
        monthButton.layer.cornerRadius = 0.5 * monthButton.bounds.width
        monthButton.clipsToBounds = true
        view.bringSubviewToFront(monthButton)
        
        determineWeeks()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         
        return weekSectionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            return 55
        }
        
        else {
    
            return 450
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "weekHeaderCell", for: indexPath) as! WeekHeaderCell
            cell.selectionStyle = .none
            
            if weekSectionArray[indexPath.section].count == 1 {
                
                formatter.dateFormat = "M/d"
                cell.weekRangeLabel.text = formatter.string(from: weekSectionArray[indexPath.section][indexPath.row])
            }
            
            else {
                
                formatter.dateFormat = "M/d"
                cell.weekRangeLabel.text = formatter.string(from: weekSectionArray[indexPath.section].first!) + " - " + formatter.string(from: weekSectionArray[indexPath.section].last!)
            }
            
            return cell
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeTableViewCell
            cell.selectionStyle = .none
            
            cell.personalCollectionContent = weekSectionArray[indexPath.section]
            
            return cell
        }
    }
    
    private func determineWeeks () {
        
        formatter.dateFormat = "M/d"
        
        let calendar = Calendar.current
        let date = Date()
        
        let interval = calendar.dateInterval(of: .month, for: date)
        
        let days = calendar.dateComponents([.day], from: interval!.start, to: interval!.end).day!
        
        
        let startOfMonth = interval!.start
        
        //print(calendar.component(.weekday, from: startOfMonth))
        
        var loopCount: Int = 0
        var weekCount: Int = 0
        
        while loopCount < days {
            
            let currentDate: Date = calendar.date(byAdding: .day, value: loopCount, to: startOfMonth)!
            
            weekSectionArray[weekCount].append(currentDate)//(formatter.string(from: currentDate))
            
            if (calendar.component(.weekday, from: currentDate) == 7) && (loopCount + 1 != days) {
                
                weekCount += 1
                weekSectionArray.append([])
            }
            
            //print(weekSectionArray)

            
            loopCount += 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let item = UIBarButtonItem()
        item.title = ""
        navigationItem.backBarButtonItem = item
    }
}
