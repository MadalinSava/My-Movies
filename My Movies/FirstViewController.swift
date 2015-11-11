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
		
		//tableView.dataSource = self
		//tableView.delegate = self
		tableView.hidden = true
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
		if let thumbnailPath = searchController.results[indexPath.row].thumbnailPath {
			//print("thumbnail for \(indexPath.row) is \(thumbnailPath)")
			dispatch_async(queue) {
				if let data = NSData(contentsOfURL: NSURL(string: "https://image.tmdb.org/t/p/w92" + thumbnailPath)!) {
					dispatch_async(dispatch_get_main_queue()) {
						//print("setting for \(indexPath.row) thumbnail \(thumbnailPath)")
						// TODO check thumbnail bug on device
						cell.thumbnail.image = UIImage(data: data)
					}
				}
			}
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
		vc.metadata = searchController.medatada[indexPath.row]
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

