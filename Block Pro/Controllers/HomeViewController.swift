//
//  HomeViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/29/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileImageContainer: UIView!
    @IBOutlet weak var faceImage: UIImageView!
    
    @IBOutlet weak var homeTableView: UITableView!
    
    var viewInitiallyLoaded: Bool = false
    
    let formatter = DateFormatter()
    
    var weekSectionArray: [[Date]] = [[]]
    
    var tableViewAutoScrolled: Bool = false
    
    var visibleCell: IndexPath?
    
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        homeTableView.showsVerticalScrollIndicator = false
        homeTableView.separatorStyle = .none
        //homeTableView.rowHeight = 430
        
        homeTableView.isPagingEnabled = true
        
        homeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "homeCell")
        
        determineWeeks()
        
        configureMonthButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        formatter.dateFormat = "MMMM"
//        navigationItem.title = formatter.string(from: Date())
//        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 25)!]
        
        configureNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if viewInitiallyLoaded == false {
            
            scrollToCurrentWeek()
            viewInitiallyLoaded = true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         
        return weekSectionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return homeTableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
        cell.selectionStyle = .none
        
        cell.personalCollectionContent = weekSectionArray[indexPath.section]
        
        cell.homeViewController = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //Checks to see if the cell matching the current date is going to be displayed; done after the tableView is autoScrolled
        if tableViewAutoScrolled == true {
            
            scrollToCurrentDay(tableView, cell, indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if visibleCell ?? nil != nil {
            
            if let cell = homeTableView.cellForRow(at: visibleCell!) as? HomeTableViewCell {
                
                cell.shrinkPersonalCell()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if decelerate == false {
            
            scrollToMostVisibleCell()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        scrollToMostVisibleCell()
    }

    
    private func configureNavBar () {
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        let newCollabButton: UIButton = UIButton(type: .system)
        newCollabButton.setImage(UIImage(named: "genius"), for: .normal)
        newCollabButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        let collab_personalButton: UIButton = UIButton(type: .system)
        collab_personalButton.frame = CGRect(x: 0, y: 0, width: 65, height: 25)
        collab_personalButton.backgroundColor = UIColor(hexString: "ECECEC", withAlpha: 0.70)
        
        collab_personalButton.layer.cornerRadius = 14
        collab_personalButton.clipsToBounds = true
        
        collab_personalButton.setTitle("Collab", for: .normal)
        collab_personalButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 13)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: newCollabButton), UIBarButtonItem(customView: collab_personalButton)]
        
        profileImageContainer.layer.shadowRadius = 2.5
        profileImageContainer.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        profileImageContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        profileImageContainer.layer.shadowOpacity = 0.75
        
        profileImageContainer.layer.borderWidth = 1
        profileImageContainer.layer.borderColor = UIColor(hexString: "F4F4F4", withAlpha: 0.05)?.cgColor
        
        profileImageContainer.layer.cornerRadius = 0.5 * profileImageContainer.bounds.width
        profileImageContainer.layer.masksToBounds = false
        profileImageContainer.clipsToBounds = false
        
        faceImage.layer.cornerRadius = 0.5 * faceImage.bounds.width
        faceImage.layer.masksToBounds = false
        faceImage.clipsToBounds = true
        
    }
    
    private func configureMonthButton () {
        
        let monthButton: UIButton = UIButton()
        monthButton.backgroundColor = .white
        
        monthButton.addTarget(self, action: #selector(monthButtonPressed), for: .touchUpInside)
        
        view.addSubview(monthButton)
        
        monthButton.translatesAutoresizingMaskIntoConstraints = false
        
        monthButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        monthButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -110).isActive = true
        monthButton.widthAnchor.constraint(equalToConstant: 67.5).isActive = true
        monthButton.heightAnchor.constraint(equalToConstant: 67.5).isActive = true

        monthButton.layer.cornerRadius = 0.5 * monthButton.bounds.size.width

        monthButton.layer.shadowRadius = 2.5
        monthButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        monthButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        monthButton.layer.shadowOpacity = 0.35

        monthButton.layer.cornerRadius = 0.5 * 67.5
        monthButton.layer.masksToBounds = false
        monthButton.clipsToBounds = false

        monthButton.layer.borderWidth = 1
        monthButton.layer.borderColor = UIColor(hexString: "F2F2F2")?.cgColor

        let monthImage = UIImageView(image: UIImage(named: "database"))
        monthImage.contentMode = .scaleToFill

        view.addSubview(monthImage)

        monthImage.translatesAutoresizingMaskIntoConstraints = false

        monthImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        monthImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120).isActive = true
        monthImage.widthAnchor.constraint(equalToConstant: 45).isActive = true
        monthImage.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    private func determineWeeks () {
        
        formatter.dateFormat = "M/d"
        
        let calendar = Calendar.current
        let date = Date()
        
        let interval = calendar.dateInterval(of: .month, for: date)
        
        let days = calendar.dateComponents([.day], from: interval!.start, to: interval!.end).day!
        
        let startOfMonth = interval!.start
        
        var loopCount: Int = 0
        var weekCount: Int = 0
        
        while loopCount < days {
            
            let currentDate: Date = calendar.date(byAdding: .day, value: loopCount, to: startOfMonth)!
            
            weekSectionArray[weekCount].append(currentDate)//(formatter.string(from: currentDate))
            
            if (calendar.component(.weekday, from: currentDate) == 7) && (loopCount + 1 != days) {
                
                weekCount += 1
                weekSectionArray.append([])
            }
            
            loopCount += 1
        }
    }
    
    private func scrollToCurrentWeek () {
        
        //homeTableView.isUserInteractionEnabled = false
        
        let currentDate: Date = Date()
        formatter.dateFormat = "MMMM d yyyy"
        
        var sectionToScrollTo: Int?
         
        var count: Int = 0
        
        for dates in weekSectionArray {
            
            for date in dates {

                if formatter.string(from: date) == formatter.string(from: currentDate) {

                    sectionToScrollTo = count

                    break
                }
            }
            
            if sectionToScrollTo != nil {
                
                break
            }
            
            count += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            
            let indexPath: IndexPath = IndexPath(row: 0, section: sectionToScrollTo ?? 0)
            self.visibleCell = IndexPath(row: 1, section: indexPath.section)
            
            if indexPath.section == 0 {
                
                let cell = self.homeTableView.cellForRow(at: self.visibleCell!)
                
                self.scrollToCurrentDay(self.homeTableView, cell!, self.visibleCell!)
            }
            
            else {
                
                self.homeTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                
                self.tableViewAutoScrolled = true
            }
        }
    }
    
    private func scrollToCurrentDay (_ tableView: UITableView, _ cell: UITableViewCell, _ indexPath: IndexPath) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            let confirmedVisibleCell: Int?

//            //If the user is not on the last section of the homeTableView
//            if indexPath.section != self.weekSectionArray.count - 1 {
//
//                confirmedVisibleCell = 1
//                //print("check1")
//            }
//
//            else {
//
//                confirmedVisibleCell = 2
//                //print("check2")
//            }
            
            confirmedVisibleCell = 0

            if tableView.cellForRow(at: indexPath) == tableView.visibleCells[confirmedVisibleCell ?? 1] {

                //print("check12")

                let currentDate: Date = Date()
                self.formatter.dateFormat = "MMMM d yyyy"

                if let homeCell = cell as? HomeTableViewCell {

                    //print("check2")

                    var indexToScrollTo: Int = 0
                    var count: Int = 0

                    for date in homeCell.personalCollectionContent {

                        if self.formatter.string(from: date) == self.formatter.string(from: currentDate) {

                            indexToScrollTo = count
                            break
                        }

                        count += 1
                    }

                    let indexPath: IndexPath = IndexPath(row: indexToScrollTo, section: 0)
                    homeCell.personalCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    homeCell.visibleItem = indexPath

                    homeCell.growPersonalCell(delay: 0.5)

                    self.homeTableView.isUserInteractionEnabled = true
                    self.tableViewAutoScrolled = false
                }
            }
        }
    }
    
    private func scrollToMostVisibleCell () {
        
        let visibleRows: [IndexPath] = homeTableView.indexPathsForVisibleRows!
        let topHalfRect: CGRect = CGRect(x: 0, y: navigationItem.accessibilityFrame.height, width: view.frame.width, height: (view.center.y - navigationItem.accessibilityFrame.height))
        var topHalfCells: [IndexPath] = []

        var count = 0

        for cell in homeTableView.visibleCells {

            let cellFrame: CGRect = CGRect(x: cell.frame.minX, y: cell.frame.minY - homeTableView.contentOffset.y, width: cell.frame.width, height: cell.frame.height)

            if cellFrame.intersects(topHalfRect) {

                topHalfCells.append(visibleRows[count])
            }

            count += 1
        }

        let indexPath: IndexPath = IndexPath(row: 0, section: topHalfCells[0][0])
        homeTableView.scrollToRow(at: indexPath, at: .top, animated: true)

        visibleCell = IndexPath(row: 0, section: indexPath.section)

        let cell = homeTableView.cellForRow(at: visibleCell!) as! HomeTableViewCell

        cell.assignVisibleCell {
            cell.growPersonalCell()
        }
    }
    
    func moveToTimeBlockView (selectedDate: Date) {
        
        self.selectedDate = selectedDate
        
        performSegue(withIdentifier: "moveToTimeBlockView", sender: self)
    }
    
    @objc private func monthButtonPressed () {
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let item = UIBarButtonItem()
        item.title = ""
        navigationItem.backBarButtonItem = item
        
        
        if segue.identifier == "moveToTimeBlockView" {
            
            let timeBlockVC = segue.destination as! TimeBlockViewController2
            timeBlockVC.currentDate = selectedDate!
        }
        

    }
}
