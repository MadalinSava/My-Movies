//
//  FirstViewController.swift
//  My Movies
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDataSource, SearchControllerDelegate, UITableViewDelegate {
	
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var tableView: UITableView!
	
	private var searchController = SearchController()
	private let queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		searchController.searchBar = searchBar
		searchController.delegate = self
		
		tableView.hidden = true
		
		searchBar.text = "matrix"//"fight bat"
		searchController.getResultsForNextPage()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: UITableViewDataSource
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let resultsCount = searchController.results.count
		if resultsCount > 0 {
			return resultsCount + (searchController.hasMoreResults ? 1 : 0)
		}
		return 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		// Loading... cell
		if indexPath.row == searchController.results.count {
			searchController.getResultsForNextPage()
			let cell = tableView.dequeueReusableCellWithIdentifier("loading")!
			return cell
		}
		
		// regular cell
		let cell = tableView.dequeueReusableCellWithIdentifier(SearchCell.reuseIdentifier) as! SearchCell
		
		let setDefaultImage = {
			cell.thumbnail.image = UIImage(named: "default")
		}
		
		if let thumbnailPath = searchController.results[indexPath.row].thumbnailPath {
			//print("thumbnail for \(indexPath.row) is \(thumbnailPath)")
			dispatch_async(queue) {
				if let data = NSData(contentsOfURL: NSURL(string: "https://image.tmdb.org/t/p/w92" + thumbnailPath)!) {
					dispatch_async(dispatch_get_main_queue()) {
						//print("setting for \(indexPath.row) thumbnail \(thumbnailPath)")
						// TODO check thumbnail bug on device
						cell.thumbnail.image = UIImage(data: data)
					}
				} else {
					//setDefaultImage()
				}
			}
		} else {
			//setDefaultImage()
		}
		cell.name.text = searchController.results[indexPath.row].name
		return cell
	}
	
	// MARK: UITableViewDelegate
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		searchBar.resignFirstResponder()
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		//print(indexPath.row)
		let pvc = parentViewController as! UITabBarController
		pvc.selectedIndex = 1
		let vc = pvc.selectedViewController as! SecondViewController
		vc.setupWithData(searchController.medatada[indexPath.row], image: (tableView.cellForRowAtIndexPath(indexPath) as! SearchCell).thumbnail.image!)
		//vc.metadata = searchController.medatada[indexPath.row]
		
		//pvc.tabBar.items![1].image = (tableView.cellForRowAtIndexPath(indexPath) as! SearchCell).thumbnail.image
	}
	
	// MARK: search controler delegate
	func resultsReset() {
		tableView.hidden = (searchController.results.count == 0)
		tableView.reloadData()
		if searchController.results.count > 0 {
			tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
		}
	}
	
	func resultsAdded(count: Int) {
		let prevCount = searchController.results.count - count
		let numRowsToInsert = count - (searchController.hasMoreResults ? 0 : 1)
		var indexPaths = [NSIndexPath]()
		for i in 0..<numRowsToInsert {
			indexPaths.append(NSIndexPath(forRow: prevCount + i, inSection: 0))
		}
		tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
	}
}

