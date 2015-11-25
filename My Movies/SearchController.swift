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
	
	private var block: dispatch_block_t! = nil
	private var currentPage = 0
	private var requestDone = true
	
	init(searchBar: UISearchBar, tableView: UITableView) {
		self.searchBar = searchBar
		self.tableView = tableView
		
		super.init()
		
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
		tableView.frame.origin.y = viewController.topLayoutGuide.length + 50
		tableView.frame.size.height = mainWindow.frame.size.height - viewController.topLayoutGuide.length - viewController.bottomLayoutGuide.length - 100
	}
	
	// MARK: UISearchBarDelegate
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		
		assert(searchBar == self.searchBar, "wrong search bar")
		
		if block != nil {
			dispatch_block_cancel(block)
		}
		// TODO: what if requestDone is false?
		currentPage = 1
		block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, doRequest)
		// TODO: not on main queue?
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
	}
	
	func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
		//searchBar.becomeFirstResponder()
		return true
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
		ImageSetter.instance.setImage(thumbPath, ofType: .Poster, andWidth: cell.thumbnail.frame.width, forView: cell.thumbnail, defaultImage: "default")
		
		cell.name.text = results[indexPath.row].name
		return cell
	}
	
	// MARK: UITableViewDelegate
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		searchBar.resignFirstResponder()
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		tableView.frame.size.height = 0.0
		//let vc = DetailsViewController()
		let st = UIStoryboard(name: "NewMain", bundle: nil)
		//aprint(st.
		let vc = st.instantiateViewControllerWithIdentifier("DetailsViewController")
		UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(vc, animated: true){}
		
		/*let vc = (parentViewController as! TabBarController).goToDetails()
		let entity = Entity.createWithData(searchController.medatada[indexPath.row])
		let image = (tableView.cellForRowAtIndexPath(indexPath) as! SearchCell).thumbnail.image!
		vc.setupWithEntity(entity, andImage: image)*/
	}
	
	// MARK: search controler delegate
	func resultsReset() {
		tableView.hidden = (results.count == 0)
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

}
