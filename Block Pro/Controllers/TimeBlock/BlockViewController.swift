//
//  BlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/16/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class BlockViewController: UIViewController {

    var hiddenBlockVC: HiddenBlocksViewController?
    
    let blockTableView = UITableView()
    let addBlockButton = UIButton(type: .system)
    let seeHiddenBlocksButton = UIButton(type: .system)
    
    let tabBar = CustomTabBar.sharedInstance
    
    let calendar = Calendar.current
    var formatter: DateFormatter?
    
    var selectedDate: Date? {
        didSet {
            
            if let date = selectedDate, let formatter = formatter {
                
                formatter.dateFormat = "EEEE, MMMM d"
                self.title = formatter.string(from: date)
            }
        }
    }
    
    var blocks: [Block]? {
        didSet {
            
            determineHiddenBlocks(blockTableView)
            blockTableView.reloadData()
            
            scrollToFirstBlock()
            
            updateSelectedBlock()
        }
    }
    
    var hiddenBlocks: [Block] = []
    var selectedBlock: Block?
    
    var scrolledToFirstBlock: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 18)!]
        
//        let shareButton = UIBarButtonItem(image: UIImage(named: "share"), style: .done, target: self, action: #selector(shareButtonPressed))
//        navigationItem.setRightBarButton(shareButton, animated: true)
        
        configureTableView()
        configureAddBlockButton()
        configureSeeHiddenBlocksButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hiddenBlockVC = nil
    }
    
    
    //MARK: - Configure Table View
    
    private func configureTableView () {
        
        self.view.addSubview(blockTableView)
        blockTableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            blockTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topBarHeight + 10),
            blockTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            blockTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            blockTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        blockTableView.dataSource = self
        blockTableView.delegate = self
        
        blockTableView.rowHeight = 2210
        
        blockTableView.separatorStyle = .none
        blockTableView.showsVerticalScrollIndicator = false

        blockTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 20 : 0, right: 0)
        blockTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 40 : 0, right: 0)
        
        blockTableView.register(BlocksTableViewCell.self, forCellReuseIdentifier: "blocksTableViewCell")
    }
    
    
    //MARK: - Configure Add Block Button
    
    private func configureAddBlockButton () {
        
        view.addSubview(addBlockButton)
        addBlockButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            addBlockButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -29),
            addBlockButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(self.view.frame.height - tabBar.frame.minY) - 25),
            addBlockButton.widthAnchor.constraint(equalToConstant: 60),
            addBlockButton.heightAnchor.constraint(equalToConstant: 60)
            
        ].forEach( { $0.isActive = true } )
        
        addBlockButton.backgroundColor = UIColor(hexString: "222222")
        addBlockButton.setImage(UIImage(named: "plus 2"), for: .normal)
        addBlockButton.tintColor = .white
        
        addBlockButton.layer.cornerRadius = 30
        addBlockButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        addBlockButton.layer.shadowRadius = 2
        addBlockButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        addBlockButton.layer.shadowOpacity = 0.65

        addBlockButton.addTarget(self, action: #selector(addBlockButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure See Hidden Blocks Button
    
    private func configureSeeHiddenBlocksButton () {
        
        self.view.addSubview(seeHiddenBlocksButton)
        seeHiddenBlocksButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            seeHiddenBlocksButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12.5),
            seeHiddenBlocksButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            seeHiddenBlocksButton.widthAnchor.constraint(equalToConstant: 35),
            seeHiddenBlocksButton.heightAnchor.constraint(equalToConstant: 35)
            
        ].forEach({ $0.isActive = true })
        
        seeHiddenBlocksButton.alpha = 0
        
        seeHiddenBlocksButton.tintColor = UIColor(hexString: "222222")
        seeHiddenBlocksButton.setImage(UIImage(systemName: "chevron.right.circle.fill"), for: .normal)
        seeHiddenBlocksButton.contentVerticalAlignment = .fill
        seeHiddenBlocksButton.contentHorizontalAlignment = .fill
        
        seeHiddenBlocksButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        seeHiddenBlocksButton.layer.shadowRadius = 2
        seeHiddenBlocksButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        seeHiddenBlocksButton.layer.shadowOpacity = 0.65
        
        seeHiddenBlocksButton.addTarget(self, action: #selector(seeHiddenBlocksButtonPressed), for: .touchUpInside)
        
        let buttonBackgroundView = UIView(frame: CGRect(x: 5, y: 5, width: 25, height: 25))
        buttonBackgroundView.backgroundColor = .white
        buttonBackgroundView.isUserInteractionEnabled = false
        
        buttonBackgroundView.layer.cornerRadius = 25 * 0.5
        buttonBackgroundView.clipsToBounds = true
        
        seeHiddenBlocksButton.addSubview(buttonBackgroundView)
        seeHiddenBlocksButton.bringSubviewToFront(seeHiddenBlocksButton.imageView!)
    }
    
    
    //MARK: - Scroll to First Block
    
    private func scrollToFirstBlock () {
        
        //If the tableView hasn't yet scrolled to the first block -- signifies that this view is being loaded for the first time
        if !scrolledToFirstBlock {
            
            //Gets the first block for the selected date
            if let date = selectedDate, let sortedBlocks = blocks?.filter({ calendar.isDate($0.starts!, inSameDayAs: date) }).sorted(by: { $0.starts! < $1.starts! }), let startTime = sortedBlocks.first?.starts {
                
                //yCoordForBlockTime
                let blockStartHour = calendar.dateComponents([.hour], from: startTime).hour!
                let blockStartMinute = calendar.dateComponents([.minute], from: startTime).minute!
                let yCoordForBlockTime = CGFloat((Double(blockStartHour) * 90) + (Double(blockStartMinute) * 1.5)) + 50
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    //Stops the tableView from scroll out of the frame of the cell
                    if yCoordForBlockTime < 2210 - self.blockTableView.frame.height {
                        
                        self.blockTableView.contentOffset.y = yCoordForBlockTime
                    }
                    
                    else {
                        
                        self.blockTableView.contentOffset.y = 2210 - self.blockTableView.frame.height
                    }
                }
            }
            
            scrolledToFirstBlock = true
        }
    }
    
    
    //MARK: - Determine Hidden Blocks
    
    func determineHiddenBlocks (_ scrollView: UIScrollView) {
        
        //Ensures that the view is expanded
        if let indexPath = blockTableView.indexPathsForVisibleRows?.first {
            
            //The range of y-Coords that is used to determine which hidden blocks can be presented
            let range = scrollView.contentOffset.y - CGFloat(2210 * indexPath.row) ... scrollView.contentOffset.y - CGFloat(2210 * indexPath.row) + scrollView.frame.height
            
            if let cell = blockTableView.cellForRow(at: indexPath) as? BlocksTableViewCell {
                
                hiddenBlocks = []
                
                for hiddenBlock in cell.hiddenBlocks {
                    
                    let blockStartHour = calendar.dateComponents([.hour], from: hiddenBlock.starts!).hour!
                    let blockStartMinute = calendar.dateComponents([.minute], from: hiddenBlock.starts!).minute!
                    let yCoord = CGFloat((Double(blockStartHour) * 90) + (Double(blockStartMinute) * 1.5)) + 50
                    
                    //If the hidden block's y-Coord is within the range meaning that it would be visible to the user if it wasn't hidden
                    if range.contains(yCoord) {
                        
                        hiddenBlocks.append(hiddenBlock)
                    }
                }
                
                //If the hiddenBlocksVC is currently in the navigation stack/presented to the user, this will update the hiddenBlocks in that view
                if let viewController = hiddenBlockVC {
                    
                    viewController.hiddenBlocks = hiddenBlocks
                }
                
                //Animating the hiddenBlocksButton based on the number of hiddenBlocks available
                if hiddenBlocks.count > 0 {
                    
                    UIView.animate(withDuration: 0.3) {
                        
                        self.seeHiddenBlocksButton.alpha = 1
                    }
                }
                
                else {
                    
                    UIView.animate(withDuration: 0.3) {
                        
                        self.seeHiddenBlocksButton.alpha = 0
                    }
                }
            }
        }
    }
    
    
    //MARK: - Format Selected Block
    
    private func formatSelectedBlock (_ block: Block?) -> Block? {

        var formattedBlock = block

        //Attempts to auto configure the block status
        if formattedBlock?.status == nil, let starts = formattedBlock?.starts, let ends = formattedBlock?.ends {

            if Date().isBetween(startDate: starts, endDate: ends) {

                formattedBlock?.status = .inProgress
            }

            else if Date() < starts {

                formattedBlock?.status = .notStarted
            }

            else if Date() > ends {

                formattedBlock?.status = .late
            }
        }

        return formattedBlock
    }
    
    
    //MARK: - Update Selected Block
    
    private func updateSelectedBlock () {
        
        //Gets the navigation controller of the visibleViewController
        if let navController = self.navigationController?.visibleViewController?.navigationController {
            
            navController.viewControllers.forEach { (viewController) in
                
                //If the selectedBlockVC is embedded within a navigation stack
                if let selectedBlockVC = viewController as? SelectedBlockViewController {
                    
                    //Finds the block that is currently selected
                    if let updatedBlock = blocks?.first(where: { $0.blockID == selectedBlockVC.block?.blockID }) {
                        
                        //Calls this func in the selectedBlockVC that will update view as required
                        selectedBlockVC.confirmBlockChanges(updatedBlock)
                    }
                    
                    //Block may have been deleted
                    else {
                        
                        selectedBlockVC.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    //MARK: - Share Button Pressed
    
//    @objc private func shareButtonPressed () {
//
//
//    }
    
    
    //MARK: - Add Block Button Pressed
    
    @objc private func addBlockButtonPressed () {
        
        let configureBlockVC: ConfigureBlockViewController = ConfigureBlockViewController()
        configureBlockVC.title = "Add a Block"
        
        //This will set the block date to be the current selected date
        if let date = selectedDate {

            //If the selectedDate is in the same day as the current date
            if calendar.isDate(date, inSameDayAs: Date()) {
                
                configureBlockVC.block.starts = Date().adjustTime(roundDown: true)
                configureBlockVC.block.ends = Date().adjustTime(roundDown: false)
            }
            
            else {
                
                configureBlockVC.block.starts = date
                configureBlockVC.block.ends = date.adjustTime(roundDown: false)
            }
        }
        
        configureBlockVC.blockCreatedDelegate = self
        
        let configureBlockNavigationController = UINavigationController(rootViewController: configureBlockVC)
        configureBlockNavigationController.navigationBar.prefersLargeTitles = true
        
        self.present(configureBlockNavigationController, animated: true, completion: nil)
    }
    
    
    //MARK: - See Hidden Blocks Button
    
    @objc private func seeHiddenBlocksButtonPressed () {
        
        hiddenBlockVC = HiddenBlocksViewController()
        hiddenBlockVC?.title = self.title
        hiddenBlockVC?.hiddenBlocks = hiddenBlocks
        hiddenBlockVC?.blockSelectedDelegate = self

        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = ""
        self.navigationItem.backBarButtonItem = backBarButtonItem

        self.navigationController?.pushViewController(hiddenBlockVC!, animated: true)
    }
    
    
    //MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToSelectedBlockView"{
            
            if let navController = segue.destination as? UINavigationController {
                
                let selectedBlockVC = navController.viewControllers.first as! SelectedBlockViewController
                selectedBlockVC.block = formatSelectedBlock(selectedBlock)
            }
            
        }
    }
}


//MARK: - TableView Extension

extension BlockViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "blocksTableViewCell", for: indexPath) as! BlocksTableViewCell
        cell.selectionStyle = .none
        
        cell.blockSelectedDelegate = self
        
        if let date = selectedDate {
            
            cell.blocks = blocks?.filter({ calendar.isDate($0.starts!, inSameDayAs: date) }).sorted(by: { $0.starts! < $1.starts! })
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        determineHiddenBlocks(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if velocity.y < 0 {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                self.addBlockButton.alpha = 1
                self.tabBar.alpha = 1
            }
        }
        
        else if velocity.y > 0.5 {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                self.addBlockButton.alpha = 0
                self.tabBar.alpha = 0
            }
        }
    }
}


//MARK: Block Created Protocol

extension BlockViewController: BlockCreatedProtocol {
    
    func blockCreated(_ block: Block) {
        
        if let date = selectedDate, let startTime = block.starts {
            
            //yCoordForBlockTime
            let blockStartHour = calendar.dateComponents([.hour], from: startTime).hour!
            let blockStartMinute = calendar.dateComponents([.minute], from: startTime).minute!
            let yCoordForBlockTime = CGFloat((Double(blockStartHour) * 90) + (Double(blockStartMinute) * 1.5)) + 50
            
            //If the user created a block that belongs to a date not within the same day as the current selected date
            if !calendar.isDate(startTime, inSameDayAs: date) {
                
                let updatedDateComponents = calendar.dateComponents([.year, .month, .day], from: startTime)
                selectedDate = calendar.date(from: updatedDateComponents)
                
                //Finds the homeVC embedded in the navigation stack
                self.navigationController?.viewControllers.forEach({ (viewController) in
                    
                    if let homeVC = viewController as? HomeViewController {
                        
                        homeVC.updateSelectedDate(date: selectedDate ?? date)
                    }
                })
                
                blockTableView.reloadData()
                
                //Gives the tableView time to reload
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    self.blockTableView.contentOffset.y = yCoordForBlockTime
                }
            }
            
            else {
                
                blockTableView.contentOffset.y = yCoordForBlockTime
            }
        }
    }
}

//MARK: - Block Selected Protocol

extension BlockViewController: BlockSelectedProtocol {
    
    func blockSelected (_ block: Block) {
        
        selectedBlock = block
        
        performSegue(withIdentifier: "moveToSelectedBlockView", sender: self)
    }
}
