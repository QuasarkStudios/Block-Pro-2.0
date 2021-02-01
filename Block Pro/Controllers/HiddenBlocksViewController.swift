//
//  HiddenBlocksViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/29/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class HiddenBlocksViewController: UIViewController {

    let tabBar = CustomTabBar.sharedInstance
    
    let hiddenBlocksTableView = UITableView()
    
    var hiddenBlocks: [Block]? {
        didSet {
            
            if hiddenBlocks?.count ?? 0 > 0 {
                
                hiddenBlocksTableView.reloadData()
            }
            
            //Will pop the view controller if there are no more hidden blocks available
            else {
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    let formatter = DateFormatter()
    
    weak var blockSelectedDelegate: BlockSelectedProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Blocks"
        
        configureTableView(hiddenBlocksTableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = .white
        
        tabBar.shouldHide = false
    }
    
    
    //MARK: - Configure Table View
    
    private func configureTableView (_ tableView: UITableView) {
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        ].forEach({ $0.isActive = true })
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        
        tableView.register(BlockCell.self, forCellReuseIdentifier: "blockCell")
    }
}


//MARK: - TableView Extension

extension HiddenBlocksViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return hiddenBlocks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath) as! BlockCell
        cell.selectionStyle = .none
        
        cell.formatter = formatter
        cell.block = hiddenBlocks?[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if hiddenBlocks?[indexPath.row].members?.count ?? 0 > 0 {
            
            return 210
        }
        
        else {
            
            return 175
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.navigationController?.popViewController(animated: true)
        
        if let block = hiddenBlocks?[indexPath.row] {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                
                self.blockSelectedDelegate?.blockSelected(block)
            }
        }
    }
}
