//
//  ViewController.swift
//  AppStoreSearch
//
//  Created by ying yang on 5/15/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    var landscapeViewController: LandscapeViewController?
    
    let searchClient = AppStoreClient.sharedInstance
    
    // MARK: IBOutlets and IBActions
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        
        // register nib file for table view cell
        
        let newNib = UINib(nibName: "SearchResultCell", bundle: nil)
        tableView.registerNib(newNib, forCellReuseIdentifier: "SearchResultCell")
        
        // fetch results
        
        do {
            try fetchedResultsController.performFetch()
        }catch(let error) {
            let error = error as NSError
            alert(error.description)
        }
        fetchedResultsController.delegate = self
    }
    
    //MARK: CoreData convenience methods
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "SearchResult")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext(){
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: search bar delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        let term = searchBar.text!
        activityIndicator.startAnimating()
        if fetchedResultsController.fetchedObjects?.count > 0 {
            for music in fetchedResultsController.fetchedObjects as! [SearchResult] {
                sharedContext.deleteObject(music)
            }
        }
        searchClient.performSearch(term, entity: "musicTrack") { (jsonResults, error) -> Void in
            self.activityIndicator.stopAnimating()
            guard error == nil else {
                self.alert(error!)
                return
            }
            
            // Get a Swift dictionary from the JSON data
            let dictionary = jsonResults as! [String: AnyObject]
            if let dicArray = dictionary["results"] as? [[String: AnyObject]] {
                if dicArray.count == 0 {
                    self.alert("No results for \(term)")
                    return
                }
                for dic in dicArray {
                    _ = SearchResult(dictionary: dic, context: self.sharedContext)
                }
            }else{
                self.alert("cannot find the key: results")
            }
            self.saveContext()
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
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "SearchResultCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! SearchResultCell
        
        if let searchResults = fetchedResultsController.fetchedObjects as? [SearchResult] {
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
        }
        return cell
    }
    
    // MARK: table view delegate methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (editingStyle) {
        case .Delete:
            let result = fetchedResultsController.objectAtIndexPath(indexPath) as! SearchResult
            
            // Remove the search result from the context
            sharedContext.deleteObject(result)
            CoreDataStackManager.sharedInstance().saveContext()
        default:
            break
        }
    }

    
    // MARK: fetched results controller delegate methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?){
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! SearchResultCell
            let result = fetchedResultsController.objectAtIndexPath(indexPath!) as! SearchResult
            configueCell(cell, withSearchResult: result)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    
    // MARK: prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let dest = segue.destinationViewController as! DetailViewController
            let indexPath = sender as! NSIndexPath
            
            dest.searchResult = fetchedResultsController.objectAtIndexPath(indexPath) as! SearchResult
        }
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .Compact:
            showLandscapeViewWithCoordinatot(coordinator)
        case .Regular, .Unspecified:
            hideLandscapeViewWithCoordinatot(coordinator)
        }
    }
    
    func showLandscapeViewWithCoordinatot(coordinator: UIViewControllerTransitionCoordinator){
        landscapeViewController = storyboard!.instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeViewController {
            
            // must set search result before calling controller.view
            
            controller.searchResults = fetchedResultsController.fetchedObjects as! [SearchResult]
            
            controller.view.frame = view.bounds
            view.addSubview(controller.view)
            addChildViewController(controller)
            controller.didMoveToParentViewController(self)
        }
    }
    
    func hideLandscapeViewWithCoordinatot(coordinator: UIViewControllerTransitionCoordinator){
        if let controller = landscapeViewController {
            controller.didMoveToParentViewController(nil)
            controller.removeFromParentViewController()
            controller.view.removeFromSuperview()
        }
    }
    
    func configueCell(cell: SearchResultCell, withSearchResult: SearchResult){
        cell.nameLabel.text = withSearchResult.name
        cell.artistNameLabel.text = withSearchResult.artistName
    }
}

