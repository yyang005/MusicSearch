//
//  ViewController.swift
//  AppStoreSearch
//
//  Created by ying yang on 5/15/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource {

    var searchResults = [searchResult]()
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        
        // register nib file for table view cell
        
        let newNib = UINib(nibName: "SearchResultCell", bundle: nil)
        tableView.registerNib(newNib, forCellReuseIdentifier: "SearchResultCell")
        
    }
    
    // MARK: search bar delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    // MARK: table view data source methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "SearchResultCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! SearchResultCell
        
        if searchResults.count == 0 {
            cell.nameLabel.text = "Nothing Found"
        }else {
            let result = searchResults[indexPath.row]
            cell.nameLabel.text = result.name
            cell.artistNameLabel.text = result.artistName
        }
        return cell
    }
}

