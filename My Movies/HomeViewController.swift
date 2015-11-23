//
//  FirstViewController.swift
//  My Movies
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, TabbedViewController, SearchControllerDelegate, UITableViewDataSource, UITableViewDelegate {
	
	static var tabIndex = -1
	
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var tableView: UITableView!
	
	private var searchController = SearchController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		searchController.searchBar = searchBar
		searchController.delegate = self
		
		tableView.hidden = true
		
		searchBar.text = "matrix"//"fight bat"
		searchController.getResultsForNextPage()
		
		tableView.registerNib(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: SearchCell.reuseIdentifier)
		//ImageSetter.instance
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
		
		let thumbPath = searchController.results[indexPath.row].thumbnailPath
		ImageSetter.instance.setImage(thumbPath, ofType: .Poster, andWidth: cell.thumbnail.frame.width, forView: cell.thumbnail, defaultImage: "default")
		
		cell.name.text = searchController.results[indexPath.row].name
		return cell
	}
	
	// MARK: UITableViewDelegate
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		searchBar.resignFirstResponder()
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let vc = (parentViewController as! TabBarController).goToDetails()
		let entity = Entity.createWithData(searchController.medatada[indexPath.row])
		let image = (tableView.cellForRowAtIndexPath(indexPath) as! SearchCell).thumbnail.image!
		vc.setupWithEntity(entity, andImage: image)
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

