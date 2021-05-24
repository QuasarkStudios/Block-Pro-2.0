//
//  ScheduleMessageViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/21/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class ScheduleMessageViewController: UIViewController {

    let blockTableView = UITableView()
    
    let initialContainer = UIView()
    let initialLabel = UILabel()
    
    let currentUser = CurrentUser.sharedInstance
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    var message: Message? {
        didSet {
            
            blockTableView.reloadData()
            
            scrollToFirstBlock()
        }
    }
    
    var members: [Member]? {
        didSet {
            
            setInitialLabelText()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        configureNavBar()
        configureTableView(blockTableView)
        configureInitialContainer()
        configureInitialLabel()
    }
    

    //MARK: - Configure Nav Bar
    
    private func configureNavBar () {
        
        self.navigationController?.navigationBar.configureNavBar()

        formatter.dateFormat = "EEEE, MMMM d"
        self.title = formatter.string(from: message?.dateForBlocks ?? Date())

        //If this view wasn't pushed onto the navigationStack from either the ConversationSchedulesViewController or the CollabMessagesAttachmentsView
        if self.navigationController?.viewControllers.count == 1 {
            
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelButtonPressed))
            cancelButton.style = .done
            self.navigationItem.leftBarButtonItem = cancelButton
        }
    }
    
    
    //MARK: - Configure TableView
    
    private func configureTableView (_ tableView: UITableView) {
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 59),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 2210
        
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(BlocksTableViewCell.self, forCellReuseIdentifier: "blocksTableViewCell")
    }
    
    
    //MARK: - Configure Initial Container
    
    private func configureInitialContainer () {
        
        self.view.addSubview(initialContainer)
        initialContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            initialContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? -29 : -20),
            initialContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? -29 : -20),
            initialContainer.widthAnchor.constraint(equalToConstant: 50),
            initialContainer.heightAnchor.constraint(equalToConstant: 50)
            
        ].forEach( { $0.isActive = true } )
        
        initialContainer.backgroundColor = UIColor(hexString: "222222")
        
        initialContainer.layer.cornerRadius = 25
        initialContainer.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        initialContainer.layer.shadowRadius = 2
        initialContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        initialContainer.layer.shadowOpacity = 0.65
    }
    
    
    //MARK: - Configure Initial Label
    
    private func configureInitialLabel () {
        
        initialContainer.addSubview(initialLabel)
        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            initialLabel.centerXAnchor.constraint(equalTo: initialContainer.centerXAnchor, constant: 0),
            initialLabel.centerYAnchor.constraint(equalTo: initialContainer.centerYAnchor, constant: 0),
            initialLabel.widthAnchor.constraint(equalToConstant: 34),
            initialLabel.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0.isActive = true })
        
        initialLabel.adjustsFontSizeToFitWidth = true
        initialLabel.font = UIFont(name: "Poppins-SemiBold", size: 20)
        initialLabel.textAlignment = .center
        initialLabel.textColor = .white
    }
    
    
    //MARK: - Scroll to First Block
    
    private func scrollToFirstBlock () {
        
        let sortedBlocks = message?.messageBlocks?.sorted(by: { $0.starts! < $1.starts! })
        
        //Gets the first block for the selected date
        if let startTime = sortedBlocks?.first?.starts {
            
            //yCoordForBlockTime
            let blockStartHour = calendar.dateComponents([.hour], from: startTime).hour!
            let blockStartMinute = calendar.dateComponents([.minute], from: startTime).minute!
            let yCoordForBlockTime = CGFloat((Double(blockStartHour) * 90) + (Double(blockStartMinute) * 1.5)) + 50
            
            //Small delay allows time for the tableView to configure itself
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                
                //Stops the tableView from scrolling out of the frame of the cell
                if yCoordForBlockTime < 2210 - self.blockTableView.frame.height {
                    
                    self.blockTableView.contentOffset.y = yCoordForBlockTime
                }
                
                else {
                    
                    self.blockTableView.contentOffset.y = 2210 - self.blockTableView.frame.height
                }
            }
        }
    }
    
    
    //MARK: - Set Initial Label Text
    
    private func setInitialLabelText () {
        
        if message?.sender == currentUser.userID {
            
            initialLabel.text = "You"
        }
        
        else if let member = members?.first(where: { $0.userID == message?.sender }) {
            
            let firstName = Array(member.firstName)
            let lastName = Array(member.lastName)
            
            initialLabel.text = "\(firstName[0])\(lastName[0])"
        }
    }
    
    
    //MARK: - Cancel Button Pressed
    
    @objc private func cancelButtonPressed () {
        
        dismiss(animated: true)
    }
}


//MARK: - TableView DataSource and Delegate Extension

extension ScheduleMessageViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "blocksTableViewCell", for: indexPath) as! BlocksTableViewCell
        cell.selectionStyle = .none
        
        cell.blocks = message?.messageBlocks?.sorted(by: { $0.starts! < $1.starts! })
        
        return cell
    }
}
