//
//  SearchController.swift
//  My Movies
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class SearchController: NSObject, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
	
	private let searchBar: UISearchBar
	private let tableView: UITableView
	
	private(set) var results: [SearchResult] = [SearchResult]()
	private(set) var medatada = [JSON]()
	private(set) var hasMoreResults = false
	
	private var requestTimer: NSTimer!
	private var currentPage = 0
	private var requestDone = true
	
	init(searchBar: UISearchBar, tableView: UITableView) {
		self.searchBar = searchBar
		self.tableView = tableView
		
		super.init()
		
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.delegate = self
		tableView.dataSource = self
		searchBar.delegate = self
		tableView.registerNib(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: SearchCell.reuseIdentifier)
	}
	
	func getResultsForNextPage() {
		guard requestDone else {
			return
		}
		++currentPage
		doRequest()
	}
	
	func addToViewController(viewController: UIViewController) {
		tableView.removeFromSuperview()
		
		let mainWindow = UIApplication.sharedApplication().keyWindow!
		mainWindow.addSubview(tableView)
		
		mainWindow.addConstraints([
			NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: viewController.topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: viewController.bottomLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: tableView, attribute: .Leading, relatedBy: .Equal, toItem: viewController.view, attribute: .Leading, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: tableView, attribute: .Trailing, relatedBy: .Equal, toItem: viewController.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
			])
		
		updateTableVisibility()
	}
	
	// MARK: UISearchBarDelegate
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		
		assert(searchBar == self.searchBar, "wrong search bar")
		
		requestTimer?.invalidate()
		requestTimer = NSTimer.schedule(1.0, target: doRequest)
		// TODO: what if requestDone is false? should cancel it, doh
		currentPage = 1
	}
	
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		searchBar.text = nil
		searchBar.resignFirstResponder()
		results.removeAll()
		resultsReset()
	}
	
	// MARK: request
	private func doRequest() {
		//print("requesting page \(currentPage)")
		self.requestDone = false
		
		Api.instance.searchMulti(searchBar.text!, page: currentPage, success: {[unowned self] (result) in
			
			let searchResults = result["results"]
			
			if self.currentPage == 1 {
				self.results.removeAll()
				self.medatada.removeAll()
			}
			
			for var i = 0; i < searchResults.count; ++i {
				if let newResult = SearchResult(data: searchResults[i]) {
					self.results.append(newResult)
					self.medatada.append(searchResults[i])
				}
			}
			
			self.hasMoreResults = (result["page"] < result["total_pages"])
			
			if self.currentPage == 1 {
				self.resultsReset()
			} else {
				self.resultsAdded(searchResults.count)
			}
			
			self.requestDone = true
		},
			error: { (error) in
				print(error.localizedDescription)
		})
	}
	
	// MARK: UITableViewDataSource
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let resultsCount = results.count
		if resultsCount > 0 {
			return resultsCount + (hasMoreResults ? 1 : 0)
		}
		return 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		// Loading... cell
		if indexPath.row == results.count {
			getResultsForNextPage()
			let cell = tableView.dequeueReusableCellWithIdentifier("loading")!
			return cell
		}
		
		// regular cell
		let cell = tableView.dequeueReusableCellWithIdentifier(SearchCell.reuseIdentifier) as! SearchCell
		
		let thumbPath = results[indexPath.row].thumbnailPath
		cell.setupWithImage(thumbPath, andText: results[indexPath.row].name)
		
		return cell
	}
	
	// MARK: UITableViewDelegate
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		searchBar.resignFirstResponder()
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		searchBar.resignFirstResponder()
		results.removeAll()
		tableView.reloadData()
		
		//let vc = DetailsViewController()
		let st = UIStoryboard(name: "NewMain", bundle: nil)
		let vc = st.instantiateViewControllerWithIdentifier("DetailsViewController") as! DetailsViewController
		//UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(vc, animated: true){}
		let nc = UIApplication.sharedApplication().keyWindow!.rootViewController as! UINavigationController
		nc.pushViewController(vc, animated: true)
		
		let entity = Entity.createWithData(medatada[indexPath.row])
		vc.setupWithEntity(entity)
	}
	
	// MARK: search controler delegate
	func resultsReset() {
		updateTableVisibility()
		tableView.reloadData()
		if results.count > 0 {
			tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
		}
	}
	
	func resultsAdded(count: Int) {
		let prevCount = results.count - count
		let numRowsToInsert = count - (hasMoreResults ? 0 : 1)
		var indexPaths = [NSIndexPath]()
		for i in 0..<numRowsToInsert {
			indexPaths.append(NSIndexPath(forRow: prevCount + i, inSection: 0))
		}
		tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.None)
	}
	
	private func updateTableVisibility() {
		tableView.hidden = (results.count == 0)
	}
}
