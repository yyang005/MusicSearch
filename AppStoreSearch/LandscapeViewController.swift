//
//  LandscapeViewController.swift
//  AppStoreSearch
//
//  Created by ying yang on 5/29/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(view.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true

        pageControl.removeConstraints(view.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        scrollView.contentSize = CGSize(width: 1000, height: 1000)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        pageControl.frame = CGRect(x: 0, y: view.bounds.height - pageControl.frame.height,
            width: view.bounds.width,
            height: pageControl.frame.height)
    }
}
