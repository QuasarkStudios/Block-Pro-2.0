//
//  FriendsViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/8/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var friendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        friendsTableView.register(UINib(nibName: "FriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendsCell")
        friendsTableView.rowHeight = 55
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "Pending Friends"
        }
        else {
            return "Friends"
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! FriendsTableViewCell
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "moveToSelectedFriend", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToSelectedFriend" {
            
            let selectedFriendVC = segue.destination as! SelectedFriendViewController
            
            selectedFriendVC.collabSelectedDelegate = self
        }
    }
    
}

extension FriendsViewController: CollabSelected {
    
    func performSegue () {
        
        performSegue(withIdentifier: "moveToCollabBlockView", sender: self)
    }
}
