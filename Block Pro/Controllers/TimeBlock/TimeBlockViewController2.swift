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
    
    let personalDatabase = PersonalRealmDatabase.sharedInstance
    
    var currentDateObject: TimeBlocksDate?
    var currentDate: Date? {
        didSet {
            
            currentDateObject = personalDatabase.findTimeBlocks(currentDate!)
        }
    }
    
    
    let formatter = DateFormatter()

    var selectedBlock: PersonalRealmDatabase.blockTuple?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        formatter.dateFormat = "EEEE, MMMM d"
        navigationItem.title =  formatter.string(from: currentDate!)
        //self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 20)!]
        
        timeBlockTableView.dataSource = self
        timeBlockTableView.delegate = self
        timeBlockTableView.rowHeight = 2210//1490
        timeBlockTableView.separatorStyle = .none
        timeBlockTableView.showsVerticalScrollIndicator = false

        timeBlockTableView.register(UINib(nibName: "TimeBlockCell", bundle: nil), forCellReuseIdentifier: "timeBlockCell")
        
        createDetailsButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        applyGradientFade()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 20)!]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        selectedBlock = nil
        
        autoScrollToBlock()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "timeBlockCell", for: indexPath) as! TimeBlockCell
        cell.selectionStyle = .none
        cell.editBlockDelegate = self
        
        return cell
    }
    
    private func applyGradientFade () {
        
        let gradientFade = CAGradientLayer()
        gradientFade.frame = gradientView.bounds
        gradientFade.colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0.75).cgColor, UIColor.clear.cgColor]
        gradientFade.locations = [0.25, 0.5, 0.9]
        
        gradientView.layer.mask = gradientFade
    }
    
    private func autoScrollToBlock () {
        
        guard let block = determineBlockToScrollTo() else { return }
        
            formatter.dateFormat = "HH"
            let startHour: Double = Double(formatter.string(from: block.begins))!
            
            formatter.dateFormat = "mm"
            let startMinute: Double = Double(formatter.string(from: block.begins))!
        
            let blockYCoord: CGFloat = CGFloat(((startHour * 90) + (startMinute * 1.5)) + 30)
            
            if (timeBlockTableView.rowHeight - blockYCoord) < timeBlockTableView.frame.height {
                
                timeBlockTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
            }
        
            else {
                
                UIView.animate(withDuration: 0.5) {

                    self.timeBlockTableView.contentOffset = CGPoint(x: 0, y: blockYCoord)
                }
            }
    }
    
    private func determineBlockToScrollTo () -> PersonalRealmDatabase.blockTuple? {
        
        if let blockArray = personalDatabase.blockArray {
            
            formatter.dateFormat = "HH:mm"
            
            for block in blockArray {
                
                let begins: Date = formatter.date(from: formatter.string(from: block.begins))!
                let ends: Date = formatter.date(from: formatter.string(from: block.ends))!
                let currentTime: Date = formatter.date(from: formatter.string(from: Date()))!
                
                if currentTime < begins || currentTime.isBetween(startDate: begins, endDate: ends) {
                    
                    return block
                }
                
                else {
                    
                    if block.blockID == blockArray.last?.blockID {
                        
                        return blockArray.first
                    }
                }
            }
        }
        
        return nil
    }
    
    @objc func detailsButtonPressed () {
        
        performSegue(withIdentifier: "moveToDetailsView", sender: self)
    }
    
    private func createDetailsButton () {
        
        let detailsButton = UIButton()

        detailsButton.backgroundColor = UIColor.white
        
        detailsButton.addTarget(self, action: #selector(detailsButtonPressed), for: .touchDown)
        
        view.addSubview(detailsButton)
        
        detailsButton.translatesAutoresizingMaskIntoConstraints = false
        
        detailsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        detailsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -110).isActive = true
        detailsButton.widthAnchor.constraint(equalToConstant: 67.5).isActive = true
        detailsButton.heightAnchor.constraint(equalToConstant: 67.5).isActive = true
        
        detailsButton.layer.cornerRadius = 0.5 * detailsButton.bounds.size.width
        //detailsButton.clipsToBounds = true
        
        detailsButton.layer.shadowRadius = 2.5
        detailsButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        detailsButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        detailsButton.layer.shadowOpacity = 0.35
        
        detailsButton.layer.cornerRadius = 0.5 * 67.5
        detailsButton.layer.masksToBounds = false
        detailsButton.clipsToBounds = false
        
        detailsButton.layer.borderWidth = 1
        detailsButton.layer.borderColor = UIColor(hexString: "F2F2F2")?.cgColor
        
        let detailsImage = UIImageView(image: UIImage(named: "list"))
        detailsImage.contentMode = .scaleToFill
        
        view.addSubview(detailsImage)
        
        detailsImage.translatesAutoresizingMaskIntoConstraints = false
        
        detailsImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        detailsImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120).isActive = true
        detailsImage.widthAnchor.constraint(equalToConstant: 45).isActive = true
        detailsImage.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToAddEditView" {
            
            let addEditVC = segue.destination as! AddEditBlockViewController
            //addEditVC.personalDatabase = personalDatabase
            addEditVC.currentDateObject = currentDateObject!
            addEditVC.currentDate = currentDate!
            addEditVC.reloadDataDelegate = self
            
//            if #available(iOS 13.0, *) {
//
//                addEditVC.modalPresentationStyle = .fullScreen
//            }
            
            guard let block = selectedBlock else { return }
            
                addEditVC.selectedBlock = block
        }
        
        else if segue.identifier == "moveToDetailsView" {

            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
}


extension TimeBlockViewController2: MoveToEditBlockView {
    
    func moveToEditView (selectedBlock: PersonalRealmDatabase.blockTuple) {
        
        self.selectedBlock = selectedBlock
        performSegue(withIdentifier: "moveToAddEditView", sender: self)
    }
}

extension TimeBlockViewController2: ReloadData {
    
    func reloadData() {
        
        _ = personalDatabase.findTimeBlocks(currentDate!)
        
        let indexPath: IndexPath = IndexPath(row: 0, section: 0)
        
        guard let cell = timeBlockTableView.cellForRow(at: indexPath) as? TimeBlockCell else { return }

            var count = cell.contentView.subviews.count - 1
            
            while count > 47 {

                cell.contentView.subviews[count].removeFromSuperview()
                count -= 1
            }

            cell.blockButtons = []
            cell.coorespondingBlocks = []
        
            cell.configureBlocks()
        
            selectedBlock = nil
        
            //timeBlockTableView.reloadData()
    }
    
    func nilSelectedBlock () {
        
        selectedBlock = nil
    }
}
