//
//  BlocksSearchCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/3/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class BlocksSearchCell: UITableViewCell {

    lazy var searchBar = SearchBar(parentViewController: self, placeholderText: "Search by name or status")
    
    weak var blocksSearchDelegate: CollabProgressProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "blocksSearchCell")
        
        self.contentView.backgroundColor = .white
        
        configureSearchBar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSearchBar () {
        
        self.contentView.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            searchBar.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25),
            searchBar.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -25),
            searchBar.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -25),
            searchBar.heightAnchor.constraint(equalToConstant: 37)
        
        ].forEach({ $0.isActive = true })
    }
    
    func searchBegan () {
        
        blocksSearchDelegate?.searchBegan()
    }
    
    @objc func searchTextChanged (searchText: String) {
        
        blocksSearchDelegate?.searchTextChanged(searchText: searchText)
    }
    
    func searchEnded (searchText: String) {
        
        blocksSearchDelegate?.searchEnded(searchText: searchText)
    }
}
