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
    
    @IBAction func pageChanged(sender: UIPageControl) {
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(self.pageControl.currentPage), y: 0)
            }, completion: nil)
    }
    
    var searchResults = [SearchResult]()
    
    var firstTime = true
    
    private var dataTasks = [NSURLSessionDataTask]()
    
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
        
        pageControl.numberOfPages = 0

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        pageControl.frame = CGRect(x: 0, y: view.bounds.height - pageControl.frame.height,
            width: view.bounds.width,
            height: pageControl.frame.height)
        if firstTime {
            firstTime = false
            tileButtons(searchResults)
        }
    }
    
    deinit{
        print("deinit \(self)")
        for task in dataTasks {
            task.cancel()
        }
    }
    
    private func tileButtons(searchResults: [SearchResult]) {
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        let scrollViewWidth = scrollView.bounds.size.width
        switch scrollViewWidth {
        case 568:
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
        case 667:
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
        case 736:
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
        default:
            break
        }
        
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
    
        var row = 0
        var column = 0
        var x = marginX
        for searchResult in searchResults {
        
            let button = UIButton(type: .Custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), forState: .Normal)
            button.frame = CGRect(x: x + paddingHorz, y: marginY + CGFloat(row)*itemHeight + paddingVert, width: buttonWidth, height: buttonHeight)
        
            scrollView.addSubview(button)
        
            downloadImage(searchResult, button: button)
        
            ++row
            if row == rowsPerPage {
                row = 0
                x += itemWidth
                ++column
                if column == columnsPerPage {
                    column = 0
                    x += marginX * 2
                }
            }
        }
        let buttonPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * scrollViewWidth, height: scrollView.bounds.height)
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }
    
    private func downloadImage(searchResult: SearchResult, button: UIButton){
        let url = NSURL(string: searchResult.artworkURL60)!
        let task = AppStoreClient.sharedInstance.taskForImage( url, downloadImageCompletionHandler: { (data, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            let image = UIImage(data: data!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                button.setImage(image, forState: .Normal)
            })
        })
        dataTasks.append(task)
    }
}

// MARK: scroll view delegate method

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let width = scrollView.bounds.width
        let currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
        pageControl.currentPage = currentPage
    }
}






