//
//  DetailViewController.swift
//  AppStoreSearch
//
//  Created by ying yang on 5/26/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimPresentationController( presentedViewController: presented, presentingViewController: presenting)
    }
}
