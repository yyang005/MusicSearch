//
//  ViewController.swift
//  AppStoreSearch
//
//  Created by ying yang on 5/15/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    let searchClient = AppStoreClient.sharedInstance
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        let term = searchBar.text!
        if term == "" {
            return
        }

        let entityName = entityFromIndex(sender.selectedSegmentIndex)
        searchClient.performSearch(term, entity: entityName) { (error) -> Void in
            guard error == nil else {
                print(error!)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    func entityFromIndex(index: Int) -> String?{
        var entityName: String?
        switch index {
            case 1: entityName = "musicTrack"
            case 2: entityName = "software"
            case 3: entityName = "ebook"
            default: break
        }
        return entityName
    }
    
    // MARK: life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        
        // register nib file for table view cell
        
        let newNib = UINib(nibName: "SearchResultCell", bundle: nil)
        tableView.registerNib(newNib, forCellReuseIdentifier: "SearchResultCell")
        
    }
    
    // MARK: search bar delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        let term = searchBar.text!
        searchClient.performSearch(term, entity: nil) { (error) -> Void in
            guard error == nil else {
                print(error!)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    // MARK: table view data source methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let searchResults = searchClient.searchResult
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "SearchResultCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! SearchResultCell
        
        let searchResults = searchClient.searchResult
        if searchResults.count == 0 {
            cell.nameLabel.text = "Nothing Found"
        }else {
            let result = searchResults[indexPath.row]
            cell.nameLabel.text = result.name
            cell.artistNameLabel.text = result.artistName
            
            let url = NSURL(string: result.artworkURL60)!
            searchClient.taskForImage(url, downloadImageCompletionHandler: { (data, error) -> Void in
                guard error == nil else {
                    print(error)
                    return
                }
                let image = UIImage(data: data!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.artworkImageView.image = image
                })
            })
        }
        return cell
    }
    
    // MARK: table view delegate methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetail", sender: indexPath)
    }
    
    
}

