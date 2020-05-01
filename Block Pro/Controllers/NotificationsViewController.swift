//
//  NotificationsViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/28/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var notificationsTableView: UITableView!
    
    lazy var firebaseCollab = FirebaseCollab()
    var collabRequests: [CollabRequest]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationsTableView.dataSource = self
        notificationsTableView.delegate = self
        
        firebaseCollab.retrieveCollabRequests { (requests) in
            
            self.collabRequests = requests
            self.notificationsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let requests = collabRequests else { return 1 }
        
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "collabRequestCell", for: indexPath)
        
        if let requests = collabRequests {
            
            cell.textLabel!.text = requests[indexPath.row].name
        }
        
        else {
            
            cell.textLabel!.text = "No Requests"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let requests = collabRequests else { return }
        
        firebaseCollab.acceptCollabRequest(collab: requests[indexPath.row]) {
            
            print("success")
        }
    }
    
    @IBAction func acceptButton(_ sender: Any) {
    }
    
    @IBAction func declineButton(_ sender: Any) {
    }
    
}
