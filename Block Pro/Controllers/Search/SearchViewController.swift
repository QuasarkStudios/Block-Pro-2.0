//
//  SearchViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/21/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import Lottie
import SVProgressHUD

class SearchViewController: UIViewController {
    
    let navBarExtensionView = UIView()
    lazy var searchBar = SearchBar(parentViewController: self, placeholderText: "Search by username")
    
    let searchResultsTableView = UITableView()
    
    let animationView = LottieAnimationView(name: "search-animation")
    let animationTitleLabel = UILabel()
    
    lazy var tabBar = CustomTabBar.sharedInstance
    
    var navBarExtensionBottomAnchor: NSLayoutConstraint?
    var tableViewTopAnchor: NSLayoutConstraint?
    
    lazy var firebaseCollab = FirebaseCollab.sharedInstance
    
    var searchWorkItem: DispatchWorkItem?
    var searchResults: [FriendSearchResult]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Search"
        
        self.navigationController?.navigationBar.configureNavBar()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        configureTableView(searchResultsTableView) //Call first to allow the link between navBar and tableView to be established correctly
        configureNavBarExtensionView()
        configureSearchBar()

        configureAnimationView()
        configureAnimationTitleLabel()
        
        configureGestureRecognizors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBar.shouldHide = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        SVProgressHUD.dismiss()
    }
    
    
    //MARK: - Configure Table View
    
    private func configureTableView (_ tableView: UITableView) {
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        tableViewTopAnchor = tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 77) //Height of the navBarExtensionView
        tableViewTopAnchor?.isActive = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        tableView.delaysContentTouches = false
        tableView.keyboardDismissMode = .onDrag
        
        tableView.isUserInteractionEnabled = false
        
        tableView.register(SearchFriendResultCell.self, forCellReuseIdentifier: "searchFriendResultCell")
    }
    
    
    //MARK: - Configure Nav Bar Extension
    
    private func configureNavBarExtensionView () {
        
        self.view.addSubview(navBarExtensionView)
        navBarExtensionView.translatesAutoresizingMaskIntoConstraints = false
        
        [

            navBarExtensionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            navBarExtensionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            navBarExtensionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            
        ].forEach({ $0.isActive = true })

        navBarExtensionBottomAnchor = navBarExtensionView.bottomAnchor.constraint(equalTo: searchResultsTableView.topAnchor, constant: 0)
        navBarExtensionBottomAnchor?.isActive = true
        
        navBarExtensionView.backgroundColor = .white
        navBarExtensionView.clipsToBounds = true
    }
    
    
    //MARK: - Configure Search Bar
    
    private func configureSearchBar () {
        
        navBarExtensionView.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            searchBar.leadingAnchor.constraint(equalTo: self.navBarExtensionView.leadingAnchor, constant: 25),
            searchBar.trailingAnchor.constraint(equalTo: self.navBarExtensionView.trailingAnchor, constant: -25),
            searchBar.bottomAnchor.constraint(equalTo: self.navBarExtensionView.bottomAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 37)
        
        ].forEach({ $0.isActive = true })
    }
    
    
    //MARK: - Configure Animation View
    
    private func configureAnimationView () {
        
        //This topBarHeight accounts for the fact that this navigationController allows large titles
        let topBarHeight = (keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) + (self.navigationController?.navigationBar.frame.height ?? 0)
        
        self.view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            animationView.topAnchor.constraint(equalTo: navBarExtensionView.bottomAnchor, constant: 0),
            animationView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            animationView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            animationView.heightAnchor.constraint(equalToConstant: (tabBar.frame.minY - (topBarHeight + 77)) * 0.8) //80% of the distance between the bottom of
                                                                                                                    //navExtensionView and top of the tabBar
        
        ].forEach({ $0.isActive = true })
        
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        
        animationView.play()
    }
    
    
    //MARK: - Configure Animation Title
    
    private func configureAnimationTitleLabel () {
        
        let topBarHeight = (keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) + (self.navigationController?.navigationBar.frame.height ?? 0)
        
        self.view.addSubview(animationTitleLabel)
        animationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            animationTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            animationTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            animationTitleLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? -22.5 : -15),
            animationTitleLabel.heightAnchor.constraint(equalToConstant: (tabBar.frame.minY - (topBarHeight + 77)) * 0.2) //Distance between the bottom of the                                                                                                                 //animation view and top of the tabBar
        
        ].forEach({ $0.isActive = true })
        
        animationTitleLabel.font = UIFont(name: "Poppins-SemiBold", size: 25)
        animationTitleLabel.textAlignment = .center
        animationTitleLabel.text = "Search for Friends"
    }
    
    
    //MARK: - Configure Gesture Recognizors
    
    private func configureGestureRecognizors () {
        
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    
    //MARK: - Search Text Changed
    
    func searchTextChanged (searchText: String) {
        
        searchWorkItem?.cancel()//Prevents multiple queries from occuring
        
        if searchText.leniantValidationOfTextEntered() {
            
            searchWorkItem = DispatchWorkItem(block: {
                
                self.firebaseCollab.queryUsers(searchText) { [weak self] (searchResults, error) in
                    
                    if error != nil {
                        
                        print(error?.localizedDescription as Any)
                    }
                    
                    //Ensures that the searchText used for the query matches the current text of the searchBar -- if not, it would signify that the query should be ignored because another may have begun, or the search was simply canceled
                    else if searchText == self?.searchBar.searchTextField.text {
                        
                        self?.searchResults = searchResults
                        
                        if self?.view != nil {
                            
                            self?.searchResultsTableView.isUserInteractionEnabled = (searchResults?.count ?? 0) > 0
                            
                            self?.animationTitleLabel.text = (searchResults?.count ?? 0) > 0 ? "Search for Friends" : "No Results"
                            
                            UIView.transition(with: self!.view, duration: 0.2, options: .transitionCrossDissolve) {
                                
                                self?.animationView.alpha = (searchResults?.count ?? 0) > 0 ? 0 : 1
                                self?.animationTitleLabel.alpha = (searchResults?.count ?? 0) > 0 ? 0 : 1
                                
                                self?.searchResultsTableView.reloadData()
                            }
                        }
                    }
                }
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: searchWorkItem!)
        }
        
        else {
            
            searchResults?.removeAll()
            
            self.searchResultsTableView.isUserInteractionEnabled = false
            
            UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.animationView.alpha = 1
                self.animationTitleLabel.alpha = 1
                
                self.searchResultsTableView.reloadData()
            }
        }
    }
    
    
    //MARK: - Dismiss Keyboard
    
    @objc private func dismissKeyboard () {
        
        searchBar.searchTextField.resignFirstResponder()
    }
}


//MARK: - TableView DataSource & Delegate Extension

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (searchResults?.count ?? 0) * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchFriendResultCell", for: indexPath) as! SearchFriendResultCell
            cell.selectionStyle = .none
            
            cell.searchResult = searchResults?[indexPath.row / 2]
            
            return cell
        }
        
        else {
            
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
            
            return 80
        }
        
        else {
            
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //Full height the tableView can be expanded to
        let tableViewExpandedHeight = Int(self.view.frame.height - topBarHeight)
        
        //Height of the content in the tableView; i.e. all the cells (height all of the homeCells + the height of all the seperator cells; don't use the contentSize property of the tableView cause it sometimes returns an incorrect value)
        let tableViewContentSize = ((searchResultsTableView.numberOfRows(inSection: 0) / 2) * 80) + ((searchResultsTableView.numberOfRows(inSection: 0) / 2) + 5)
        
        //If all the cells won't fit into a fully expanded tableView
        if tableViewContentSize > tableViewExpandedHeight {
            
            //If the last cell is about to be presented
            if indexPath.row + 1 == tableView.numberOfRows(inSection: 0) {
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.searchResultsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    self.searchResultsTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

                    self.tabBar.alpha = 0
                })
            }
        }
        
        else {
            
            //If the last cell is about to be presented
            if indexPath.row + 1 == tableView.numberOfRows(inSection: 0) {
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    
                    //Bottom inset in 5 points larger than the navBarExtensionView
                    self.searchResultsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 82, right: 0)
                    self.searchResultsTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 82 + 15, right: 0)
                    
                    self.tabBar.alpha = 1
                })
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//        //If the last cell is about to be dismissed
//        if indexPath.row + 1 == tableView.numberOfRows(inSection: 0), !tableView.isDragging {
//
//            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
//
//                self.searchResultsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                self.searchResultsTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//
//                self.tabBar.alpha = 1
//            })
//        }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
        //Signifies that the constraints for the tableView have been configured
        if searchResultsTableView.frame != .zero {
            
            if scrollView.contentOffset.y >= 0 {

                //If the navBarExtensionView hasn't been completely shrunken yet
                if ((tableViewTopAnchor?.constant ?? 0) - scrollView.contentOffset.y) > 0 {

                    tableViewTopAnchor?.constant -= scrollView.contentOffset.y
                    scrollView.contentOffset.y = 0
                }

                else {

                    tableViewTopAnchor?.constant = 0
                }
            }

            else {
                
                //If the navBarExtensionView hasn't been completely expanded
                if (tableViewTopAnchor?.constant ?? 0) < 77 {

                    tableViewTopAnchor?.constant = 77

                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                        self.view.layoutIfNeeded()
                    })
                }

                else {

                    navBarExtensionBottomAnchor?.constant = -scrollView.contentOffset.y //Grows the view the more the tableView is scrolled down
                }
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        //Full height the tableView can be expanded to
        let tableViewExpandedHeight = Int(self.view.frame.height - topBarHeight)
        
        //Height of the content in the tableView; i.e. all the cells (height all of the homeCells + the height of all the seperator cells; don't use the contentSize property of the tableView cause it sometimes returns an incorrect value)
        let tableViewContentSize = ((searchResultsTableView.numberOfRows(inSection: 0) / 2) * 80) + ((searchResultsTableView.numberOfRows(inSection: 0) / 2) + 5)
        
        //If all the cells won't fit into a fully expanded tableView
        if tableViewContentSize > tableViewExpandedHeight {
            
            if velocity.y < 0 {
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                    self.tabBar.alpha = 1
                })
            }
            
            else if velocity.y > 0.5 {

                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                    self.tabBar.alpha = 0
                })
            }
        }
    }
}
