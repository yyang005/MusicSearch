//
//  ViewController.swift
//  AppStoreSearch
//
//  Created by ying yang on 5/15/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }


}

