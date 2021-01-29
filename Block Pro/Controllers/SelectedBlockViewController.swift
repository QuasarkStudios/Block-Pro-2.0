//
//  SelectedBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/22/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

class SelectedBlockViewController: UIViewController {

    let selectedBlockTableView = UITableView()
    
    var copiedAnimationView: CopiedAnimationView?
    
    let firebaseBlock = FirebaseBlock.sharedInstance
    
    var collab: Collab?
    var block: Block?
    
    let formatter = DateFormatter()
    
    var zoomingMethods: ZoomingImageViewMethods?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        configureCancelBarButtonItem()
        
        self.title = block?.name
        
        configureTableView(selectedBlockTableView)
        
        monitorBlock()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.configureNavBar()
        self.navigationItem.largeTitleDisplayMode = .never
        
        copiedAnimationView = CopiedAnimationView() //Intialize here
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        copiedAnimationView?.removeCopiedAnimation(remove: true)
    }
    
    deinit {
        
        firebaseBlock.blockListener?.remove()
    }
    
    
    //MARK: - Configure Cancel Bar Button
    
    private func configureCancelBarButtonItem () {
        
        let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelButtonPressed))
        cancelBarButtonItem.style = .done
        
        self.navigationItem.leftBarButtonItem = cancelBarButtonItem
    }
    
    
    //MARK: - Configure Table View
    
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
    
    
    //MARK: - Monitor Block
    
    private func monitorBlock () {
        
        firebaseBlock.monitorCollabBlock(collab!, block?.blockID ?? "") { [weak self] (block, error) in
            
            if error != nil {
                
                print(error as Any)
            }
            
            //Ensures the block hasn't been deleted
            else if block != nil {
                
                var indexPathsToReload: [IndexPath] = []
                
                //Block Name////////////////////////////////////////////////////////////
                if let blockName = block?.name, blockName != self?.block?.name {
                    
                    self?.title = blockName
                    
                    self?.block?.name = block?.name
                }
                ////////////////////////////////////////////////////////////////////////
                
                
                //Block Time////////////////////////////////////////////////////////////
                if let starts = block?.starts, let ends = block?.ends {
                    
                    if starts != self?.block?.starts || ends != self?.block?.ends {
                        
                        indexPathsToReload.append(IndexPath(row: 0, section: 0))
                        
                        self?.block?.starts = block?.starts
                        self?.block?.ends = block?.ends
                    }
                }
                ////////////////////////////////////////////////////////////////////////
                
                
                //Block Members////////////////////////////////////////////////////////////
                if let members = block?.members {
                    
                    if members.count != self?.block?.members?.count ?? 0 {
                        
                        indexPathsToReload.append(IndexPath(row: 4, section: 0))
                    }
                    
                    else {
                        
                        for member in members {
                            
                            //If there is a member that isn't currently in the cachedBlock member array
                            if !(self?.block?.members?.contains(where: { $0.userID == member.userID }) ?? false) {
                                
                                indexPathsToReload.append(IndexPath(row: 4, section: 0))
                                break
                            }
                        }
                    }
                    
                    self?.block?.members = block?.members
                }
                ////////////////////////////////////////////////////////////////////////////
                
                
                //Block Locations////////////////////////////////////////////////////////////
                if let locations = block?.locations {
                    
                    if locations.count != self?.block?.locations?.count ?? 0 {
                        
                        indexPathsToReload.append(IndexPath(row: 6, section: 0))
                    }
                    
                    else {
                        
                        for location in locations {
                            
                            //If there is a location that isn't currently in the cachedBlock location array
                            if !(self?.block?.locations?.contains(where: { $0.locationID == location.locationID }) ?? false) {
                                
                                indexPathsToReload.append(IndexPath(row: 6, section: 0))
                                break
                            }
                            
                            //If a location has had it's name changed
                            else if let cachedLocation = self?.block?.locations?.first(where: { $0.locationID == location.locationID }), cachedLocation.name != location.name {
                                
                                indexPathsToReload.append(IndexPath(row: 6, section: 0))
                                break
                            }
                        }
                    }
                    
                    self?.block?.locations = block?.locations
                }
                /////////////////////////////////////////////////////////////////////////////
                
                
                //Block Photos////////////////////////////////////////////////////////////
                if let photoIDs = block?.photoIDs {
                    
                    if photoIDs.count != self?.block?.photoIDs?.count ?? 0 {
                        
                        indexPathsToReload.append(IndexPath(row: 8, section: 0))
                    }
                    
                    else {
                        
                        for photoID in photoIDs {
                            
                            //If there is a photoID that isn't currently in the cachedBlock photoID array
                            if !(self?.block?.photoIDs?.contains(where: { $0 == photoID }) ?? false) {
                                
                                indexPathsToReload.append(IndexPath(row: 8, section: 0))
                                break
                            }
                        }
                    }
                    
                    self?.block?.photoIDs = block?.photoIDs
                }
                //////////////////////////////////////////////////////////////////////////
                
                
                //Block Voice Memos////////////////////////////////////////////////////////////
                if let voiceMemos = block?.voiceMemos {
                    
                    if voiceMemos.count != self?.block?.voiceMemos?.count ?? 0 {
                        
                        indexPathsToReload.append(IndexPath(row: 10, section: 0))
                    }
                    
                    else {
                        
                        for voiceMemo in voiceMemos {
                            
                            //If there is a voiceMemo that isn't currently in the cachedBlock voiceMemo array
                            if !(self?.block?.voiceMemos?.contains(where: { $0.voiceMemoID == voiceMemo.voiceMemoID }) ?? false) {
                                
                                indexPathsToReload.append(IndexPath(row: 10, section: 0))
                                break
                            }
                            
                            //If a voice memo has had it's name changed
                            else if let cachedVoiceMemo = self?.block?.voiceMemos?.first(where: { $0.voiceMemoID == voiceMemo.voiceMemoID }), cachedVoiceMemo.name != voiceMemo.name {
                                
                                indexPathsToReload.append(IndexPath(row: 10, section: 0))
                                break
                            }
                        }
                    }
                    
                    self?.block?.voiceMemos = block?.voiceMemos
                }
                ///////////////////////////////////////////////////////////////////////////////
                
                
                //Block Links////////////////////////////////////////////////////////////
                if let links = block?.links {
                    
                    if links.count != self?.block?.links?.count ?? 0 {
                        
                        indexPathsToReload.append(IndexPath(row: 12, section: 0))
                    }
                    
                    else {
                        
                        for link in links {
                            
                            //If there is a link that isn't currently in the cachedBlock link array
                            if !(self?.block?.links?.contains(where: { $0.linkID == link.linkID }) ?? false) {
                                
                                indexPathsToReload.append(IndexPath(row: 12, section: 0))
                                break
                            }
                            
                            //If a link has had its name changed
                            else if let cachedLink = self?.block?.links?.first(where: { $0.linkID == link.linkID }), cachedLink.name != link.name {
                                
                                indexPathsToReload.append(IndexPath(row: 12, section: 0))
                                break
                            }
                        }
                    }
                    
                    self?.block?.links = block?.links
                }
                //////////////////////////////////////////////////////////////////////////
                
                
                //Block Status////////////////////////////////////////////////////////////
                if let status = block?.status, status != self?.block?.status {
                    
                    //If the BlockStatusCell is visible
                    if self?.selectedBlockTableView.indexPathsForVisibleRows?.contains(where: { $0.row == 14 }) ?? false {
                        
                        if let statusCell = self?.selectedBlockTableView.cellForRow(at: IndexPath(row: 14, section: 0)) as? SelectedBlockStatusCell {
                            
                            statusCell.block = block
                            
                            let statusArray: [BlockStatus : Int] = [.notStarted : 0, .inProgress : 1, .completed : 2, .needsHelp : 3, .late : 4]
                            
                            if statusArray[status] != nil {
                                
                                statusCell.statusCollectionView.scrollToItem(at: IndexPath(item: statusArray[status]!, section: 0), at: .centeredHorizontally, animated: true)
                            }
                        }
                    }
                    
                    self?.block?.status = status
                }
                //////////////////////////////////////////////////////////////////////////
                
                
                //Block Reminders////////////////////////////////////////////////////////////
                self?.determineBlockReminders(block?.blockID) { [weak self] (reminders) in
                    
                    self?.block?.reminders = reminders
                    
                    DispatchQueue.main.async {
                        
                        self?.selectedBlockTableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
                    }
                }
                
                //Reloading the cells that need updating
                self?.selectedBlockTableView.reloadRows(at: indexPathsToReload, with: .none)
            }
            /////////////////////////////////////////////////////////////////////////////////
            
            
            //Block has been deleted
            else {
                
                self?.dismiss(animated: true, completion: {
                    
                    if let blockName = self?.block?.name {
                        
                        SVProgressHUD.showInfo(withStatus: "\"\(blockName)\" has been deleted")
                    }
                })
            }
        }
    }
    
    
    //MARK: - Determine Block Reminders
    
    private func determineBlockReminders (_ blockID: String?, completion: @escaping ((_ reminders: [Int]) -> Void)) {
        
        let notificationScheduler = NotificationScheduler()
        var reminders: [Int] = []
        
        notificationScheduler.getPendingNotifications { (requests) in
            
            if let blockID = blockID {
                
                //Looping through the pending notification requests
                for request in requests {
                    
                    //If a request identifier contains the blockID
                    if request.identifier.contains(blockID) {
                        
                        let requestID = Array(request.identifier)
                        
                        //Get the last char in the identifier's string, which will be used to determine which reminder the user selected
                        if let reminder = requestID.last, Int(String(reminder)) != nil {
                            
                            reminders.append(Int(String(reminder))!)
                        }
                    }
                }
                
                completion(reminders)
            }
        }
    }
    
    
    //MARK: - Load Remaining Voice Memos
    
    private func loadRemainingVoiceMemos () {
        
        //Loads all the voiceMemos so they can be played in the EditBlockViewController
        for voiceMemo in block?.voiceMemos ?? [] {
            
            //If this voiceMemo hasn't yet been loaded
            if !FileManager.default.fileExists(atPath: documentsDirectory.path + "/VoiceMemos" + "\(voiceMemo.voiceMemoID ?? "").m4a") {
                
                let firebaseStorage = FirebaseStorage()
                
                if let collabID = collab?.collabID, let blockID = block?.blockID, let voiceMemoID = voiceMemo.voiceMemoID {
                    
                    firebaseStorage.retrieveCollabBlockVoiceMemosFromStorage(collabID, blockID, voiceMemoID) { (progress, error) in
                        
                        if error != nil {
                            
                            print(error?.localizedDescription as Any)
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: - Present Delete Block Alert
    
    private func presentDeleteBlockAlert () {
        
        let deleteAlert = UIAlertController(title: "Delete this Block?", message: "All data associated with this block will also be deleted", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] (deleteAction) in
            
            self?.deleteBlock()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        deleteAlert.addAction(deleteAction)
        deleteAlert.addAction(cancelAction)
        
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - Delete Block
    
    private func deleteBlock () {
        
        firebaseBlock.blockListener?.remove()

        if let collabID = collab?.collabID, let block = block {

            firebaseBlock.deleteCollabBlock(collabID, block) { [weak self] (error) in

                if error != nil {

                    print(error?.localizedDescription as Any)

                    SVProgressHUD.showError(withStatus: "Sorry, something went wrong while deleting this block")
                }

                else {

                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    //MARK: - Prepare for Segue
    
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
            configureBlockVC.title = "Edit a Block"
            configureBlockVC.collab = collab
            configureBlockVC.block = block ?? Block()
            
            let backButtonItem = UIBarButtonItem()
            backButtonItem.title = ""
            self.navigationItem.backBarButtonItem = backButtonItem
        }
    }
    
    
    //MARK: - Cancel Button Pressed
    
    @objc private func cancelButtonPressed () {
        
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: - TableView Extension

extension SelectedBlockViewController: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Number of Rows
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 18
    }
    
    
    //MARK: - Cell for Row
    
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
    
    
    //MARK: - Height for Row
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        
            //Name Cell
            case 0:
                
                return 80
               
            //Seperator Cell
            case 1:
                
                return 0
                
            //Reminders Cell
            case 2:
                
                return 35
                
            case 3:
                
                return 20
             
            //Members Cell
            case 4:
                
                if block?.members?.count ?? 0 > 0 {
                    
                    return 145
                }
                
                else {
                    
                    return 35
                }
               
            //Locations Cell
            case 6:
                
                if block?.locations?.count ?? 0 == 0 {
                    
                    return itemSize + 30 + 20
                }
                
                else if block?.locations?.count == 1 {
                    
                    return 210
                }
                
                else {
                    
                    return 252.5//210 + 27.5
                }
               
            //Seperator Cell
            case 7:
                
                if block?.locations?.count ?? 0 > 1 {
                    
                    return 0
                }
                
                else {
                    
                    return 25
                }
               
            //Photo Cell
            case 8:
                
                if block?.photoIDs?.count ?? 0 <= 3 {
                    
                    return itemSize + 30 + 20
                }
                
                else {
                    
                    return (itemSize * 2) + 30 + 20 + 5
                }
             
            //Voice Memos Cell
            case 10:
                
                return itemSize + 30 + 20
                
            //Links Cell
            case 12:
                
                if block?.links?.count ?? 0 == 0 {
                    
                    return itemSize + 30 + 20
                }
                
                else if block?.links?.count ?? 0 < 3 {
                    
                    return 130
                }
                
                else {
                    
                    return 157.5
                }
              
            //Status Cell
            case 14:
                
                return 100
                
            //Seperator Cell
            case 15:
                
                return 30
               
            //Edit-Delete Cell
            case 16:
                
                return 50
              
            //Seperator Cell
            default:
                
                return 25
        }
    }
    
    
    //MARK: - Will Display Cell
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let statusCell = cell as? SelectedBlockStatusCell, let blockStatus = block?.status {
            
            let statusArray: [BlockStatus : Int] = [.notStarted : 0, .inProgress : 1, .completed : 2, .needsHelp : 3, .late : 4]
            
            if statusArray[blockStatus] != nil {
                
                statusCell.statusCollectionView.scrollToItem(at: IndexPath(item: statusArray[blockStatus]!, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }
}


//MARK: - Location Selected Protocol

extension SelectedBlockViewController: LocationSelectedProtocol {
    
    func locationSelected(_ location: Location?) {
        
        performSegue(withIdentifier: "moveToLocationsView", sender: self)
    }
}


//MARK: - Cache Photo Protocol

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


//MARK: - Present Copied Animation Protocol

extension SelectedBlockViewController: PresentCopiedAnimationProtocol {
    
    func presentCopiedAnimation() {
        
        if let navBar = navigationController?.navigationBar {
            
            let navBarFrame = navBar.convert(navBar.frame, to: keyWindow)
            copiedAnimationView?.presentCopiedAnimation(topAnchor: navBarFrame.maxY + 10)
        }
    }
}


//MARK: - Zoom In Protocol

extension SelectedBlockViewController: ZoomInProtocol {
    
    func zoomInOnPhotoImageView(photoImageView: UIImageView) {
        
        zoomingMethods = ZoomingImageViewMethods(on: photoImageView, cornerRadius: 8)
        
        zoomingMethods?.performZoom()
    }
}


//MARK: - Cache Icon Protocol

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


//MARK: - Block Edited/Deleted Protocol

extension SelectedBlockViewController: BlockEdited_DeletedProtocol {
    
    func editBlockSelected() {
        
        loadRemainingVoiceMemos()
        
        performSegue(withIdentifier: "moveToConfigureBlockView", sender: self)
    }
    
    func deleteBlockSelected() {
        
        presentDeleteBlockAlert()
    }
}
