//
//  SelectedBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/22/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class SelectedBlockViewController: UIViewController {

    let selectedBlockTableView = UITableView()
    
    var copiedAnimationView: CopiedAnimationView?
    
    var collab: Collab?
    var block: Block?
    
    let formatter = DateFormatter()
    
    var zoomingMethods: ZoomingImageViewMethods?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(hexString: "222222") as Any, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.bold)]
        self.navigationController?.navigationBar.prefersLargeTitles = true
        configureCancelBarButtonItem()
        
        self.title = block?.name
        
        configureTableView(selectedBlockTableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.configureNavBar()
        self.navigationItem.largeTitleDisplayMode = .never
        
        copiedAnimationView = CopiedAnimationView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        copiedAnimationView?.removeCopiedAnimation(remove: true)
    }
    
    private func configureCancelBarButtonItem () {
        
        let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelButtonPressed))
        cancelBarButtonItem.style = .done
        
        self.navigationItem.leftBarButtonItem = cancelBarButtonItem
    }
    
    private func configureTableView (_ tableView: UITableView) {
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        tableView.delaysContentTouches = false
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        tableView.register(SelectedBlockTimeCell.self, forCellReuseIdentifier: "selectedBlockTimeCell")
        tableView.register(SelectedBlockReminderCell.self, forCellReuseIdentifier: "selectedBlockReminderCell")
        tableView.register(SelectedBlockMembersCell.self, forCellReuseIdentifier: "selectedBlockMembersCell")
        tableView.register(SelectedBlockStatusCell.self, forCellReuseIdentifier: "selectedBlockStatusCell")
        tableView.register(SelectedBlockEdit_DeleteCell.self, forCellReuseIdentifier: "selectedBlockEdit_DeleteCell")
        
        tableView.register(LocationsPresentationCell.self, forCellReuseIdentifier: "locationsPresentationCell")
        tableView.register(PhotosPresentationCell.self, forCellReuseIdentifier: "photosPresentationCell")
        tableView.register(VoiceMemosPresentationCell.self, forCellReuseIdentifier: "voiceMemosPresentationCell")
        tableView.register(LinksPresentationCell.self, forCellReuseIdentifier: "linksPresentationCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToLocationsView" {
            
            let locationVC = segue.destination as! LocationsViewController
            locationVC.locations = block?.locations
            
            if let cell = selectedBlockTableView.cellForRow(at: IndexPath(row: 6, section: 0)) as? LocationsPresentationCell {
                
                locationVC.selectedLocationIndex = cell.selectedLocationIndex
            }
            
            let backButtonItem = UIBarButtonItem()
            backButtonItem.title = ""
            self.navigationItem.backBarButtonItem = backButtonItem
        }
        
        else if segue.identifier == "moveToConfigureBlockView" {
            
            let configureBlockVC = segue.destination as! ConfigureBlockViewController
            configureBlockVC.block = block ?? Block()
            
            let backButtonItem = UIBarButtonItem()
            backButtonItem.title = ""
            self.navigationItem.backBarButtonItem = backButtonItem
        }
    }
    
    @objc private func cancelButtonPressed () {
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension SelectedBlockViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 18
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectedBlockTimeCell", for: indexPath) as! SelectedBlockTimeCell
            cell.selectionStyle = .none
            
            cell.formatter = formatter
            cell.starts = block?.starts
            cell.ends = block?.ends
            
            return cell
        }
        
        else if indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectedBlockReminderCell", for: indexPath) as!
                SelectedBlockReminderCell
            cell.selectionStyle = .none
            
            cell.formatter = formatter
            cell.block = block
            
            return cell
        }
        
        else if indexPath.row == 4 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectedBlockMembersCell", for: indexPath) as! SelectedBlockMembersCell
            cell.selectionStyle = .none
            
            cell.block = block
            
            return cell
        }
        
        else if indexPath.row == 6 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationsPresentationCell", for: indexPath) as! LocationsPresentationCell
            cell.selectionStyle = .none
            
            cell.locations = block?.locations
            
            cell.locationSelectedDelegate = self
            
            return cell
        }
        
        else if indexPath.row == 8 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "photosPresentationCell", for: indexPath) as! PhotosPresentationCell
            cell.selectionStyle = .none
            
            cell.collab = collab
            cell.block = block
            cell.photoIDs = block?.photoIDs
            
            cell.cachePhotoDelegate = self
            cell.zoomInDelegate = self
            cell.presentCopiedAnimationDelegate = self
            
            return cell
        }
        
        else if indexPath.row == 10 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "voiceMemosPresentationCell", for: indexPath) as! VoiceMemosPresentationCell
            cell.selectionStyle = .none
            
            cell.collab = collab
            cell.block = block
            
            cell.voiceMemos = block?.voiceMemos
            
            return cell
        }
        
        else if indexPath.row == 12 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "linksPresentationCell", for: indexPath) as! LinksPresentationCell
            cell.selectionStyle = .none
            
            cell.links = block?.links
            
            cell.cacheIconDelegate = self
            
            return cell
        }
        
        else if indexPath.row == 14 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectedBlockStatusCell", for: indexPath) as! SelectedBlockStatusCell
            cell.selectionStyle = .none
            
            cell.collab = collab
            cell.block = block
            
            return cell
        }
        
        else if indexPath.row == 16 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectedBlockEdit_DeleteCell", for: indexPath) as! SelectedBlockEdit_DeleteCell
            cell.selectionStyle = .none
            
            cell.blockEdited_DeletedDelegate = self
            
            return cell
        }
        
        else {
            
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            return 80
        }
        
        else if indexPath.row == 1 {
            
            return 0
        }
        
        else if indexPath.row == 2 {
            
            return 35
        }
        
        else if indexPath.row == 4 {
            
            return 145
        }
        
        else if indexPath.row == 6 {
            
            if block?.locations?.count ?? 0 == 0 {
                
                return itemSize + 30 + 20
            }
            
            else if block?.locations?.count == 1 {
                
                return 210
            }
            
            else {
                
                return 210 + 27.5
            }
        }
        
        else if indexPath.row == 8 {
            
            if block?.photoIDs?.count ?? 0 <= 3 {
                
                return itemSize + 30 + 20
            }
            
            else {
                
                return (itemSize * 2) + 30 + 20 + 5
            }
        }
        
        else if indexPath.row == 10 {
            
            return itemSize + 30 + 20
        }
        
        else if indexPath.row == 12 {
            
            if block?.links?.count ?? 0 == 0 {
                
                return itemSize + 30 + 20
            }
            
            else if block?.links?.count ?? 0 < 3 {
                
                return 130
            }
            
            else {
                
                return 157.5
            }
        }
        
        else if indexPath.row == 14 {
            
            return 100
        }
        
        else if indexPath.row == 15 {
            
            return 30
        }
        
        else if indexPath.row == 16 {
            
            return 50
        }
        
        else {
            
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let statusCell = cell as? SelectedBlockStatusCell, let blockStatus = block?.status {
            
            let statusArray: [BlockStatus : Int] = [.notStarted : 0, .inProgress : 1, .completed : 2, .needsHelp : 3, .late : 4]
            
            if statusArray[blockStatus] != nil {
                
                statusCell.statusCollectionView.scrollToItem(at: IndexPath(item: statusArray[blockStatus]!, section: 0), at: .left, animated: true)
            }
        }
    }
}

extension SelectedBlockViewController: LocationSelectedProtocol {
    
    func locationSelected(_ location: Location?) {
        
        performSegue(withIdentifier: "moveToLocationsView", sender: self)
    }
}

extension SelectedBlockViewController: CachePhotoProtocol {
    
    func cacheBlockPhoto(photoID: String, photo: UIImage?) {
        
        if block?.photos == nil {
            
            block?.photos = [:]
        }
        
        block?.photos?[photoID] = photo
    }
    
    func cacheCollabPhoto(photoID: String, photo: UIImage?) {}
    
    func cacheMessagePhoto(messageID: String, photo: UIImage?) {}
}

extension SelectedBlockViewController: PresentCopiedAnimationProtocol {
    
    func presentCopiedAnimation() {
        
        if let navBar = navigationController?.navigationBar {
            
            let navBarFrame = navBar.convert(navBar.frame, to: keyWindow)
            copiedAnimationView?.presentCopiedAnimation(topAnchor: navBarFrame.maxY + 10)
        }
    }
}

extension SelectedBlockViewController: ZoomInProtocol {
    
    func zoomInOnPhotoImageView(photoImageView: UIImageView) {
        
        zoomingMethods = ZoomingImageViewMethods(on: photoImageView, cornerRadius: 8)
        
        zoomingMethods?.performZoom()
    }
}

extension SelectedBlockViewController: CacheIconProtocol {
    
    func cacheIcon (linkID: String, icon: UIImage?) {
        
        if let linkIndex = block?.links?.firstIndex(where: { $0.linkID == linkID }) {
            
            block?.links?[linkIndex].icon = icon != nil ? icon : UIImage(named: "link")
            
            if let cell = selectedBlockTableView.cellForRow(at: IndexPath(row: 12, section: 0)) as? LinksPresentationCell {
                
                cell.links = block?.links
            }
        }
    }
}

extension SelectedBlockViewController: BlockEdited_DeletedProtocol {
    
    func editBlockSelected() {
        
        performSegue(withIdentifier: "moveToConfigureBlockView", sender: self)
    }
    
    func deleteBlockSelected() {
        
    }
}
