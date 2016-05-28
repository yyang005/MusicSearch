//
//  DetailViewController.swift
//  AppStoreSearch
//
//  Created by ying yang on 5/26/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var searchResult: SearchResult!

    // MARK: IBOutlets and IBAction
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func openURL() {
        if let url = NSURL(string: searchResult.storeURL) {
            if UIApplication.sharedApplication().canOpenURL(url){
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    // MARK: life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        popupView.layer.cornerRadius = 10
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "close")
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        if let _ = searchResult {
            updateUI()
        }
    }
    
    // MARk: update UI
    
    func updateUI() {
        nameLabel.text = searchResult.name
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = "Unknown"
        }else {
            artistNameLabel.text = searchResult.artistName
        }
        kindLabel.text = searchResult.kind
        genreLabel.text = searchResult.genre
        
        // format price display
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = searchResult.currency
        
        var priceText: String = ""
        if searchResult.price == 0 {
            priceText = "Free"
        }else if let text = formatter.stringFromNumber(searchResult.price){
            priceText = text
        }
        priceButton.setTitle(priceText, forState: .Normal)
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimPresentationController( presentedViewController: presented, presentingViewController: presenting)
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return touch.view === self.view
    }
}