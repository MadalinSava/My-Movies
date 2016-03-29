//
//  SearchController.swift
//  My Movies
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Cartography
import SwiftyJSON

class SearchController: NSObject, UITableViewDataSource {
	
	private let searchBar: UISearchBar
	private let tableView: UITableView
	
	private var results: [SearchResult] = [SearchResult]() {
		didSet {
			let newCount = results.count
			let prevCount = oldValue.count
			if newCount == 0 || prevCount == 0 {
				tableView.reloadData()
			} else {
				let numRowsToInsert = newCount - prevCount + (hasMoreResults ? 1 : 0) - (prevCount == 0 ? 0 : 1)
				let indexPaths = (0..<numRowsToInsert).map { NSIndexPath(forRow: prevCount + $0, inSection: 0) }
				tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
				
				if prevCount == 0 {
					tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
				}
			}
			tableView.hidden = (newCount == 0)
		}
	}
	
	private var medatada = [JSON]()
	private var hasMoreResults = false
	
	private let getNextPage = PublishSubject<()>()
	
	init(searchBar: UISearchBar, tableView: UITableView) {
		self.searchBar = searchBar
		self.tableView = tableView
		
		super.init()
		
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.dataSource = self
		tableView.registerNib(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: SearchCell.reuseIdentifier)
		
		self.setupSearch()
		
		self.setupActions()
	}
	
	func addToViewController(viewController: UIViewController) {
		tableView.removeFromSuperview()
		
		let mainWindow = UIApplication.sharedApplication().keyWindow!
		mainWindow.addSubview(tableView)
		
		constrain(tableView, viewController.topLayoutGuide, viewController.bottomLayoutGuide, viewController.view) {
			table, top, bottom, vcView in
			table.top == top.bottom
			table.bottom == bottom.top
			table.leading == vcView.leading
			table.trailing == vcView.trailing
		}
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
			getNextPage.onNext()
			
			let cell = tableView.dequeueReusableCellWithIdentifier("loading")!
			return cell
		}
		
		// regular cell
		let cell = tableView.dequeueReusableCellWithIdentifier(SearchCell.reuseIdentifier) as! SearchCell
		
		let thumbPath = results[indexPath.row].thumbnailPath
		cell.setupWithImage(thumbPath, andText: results[indexPath.row].name)
		
		return cell
	}
	
	// MARK: request
	private func newRequest(page: Int) -> Observable<()> {
		return Api.instance.searchMultiRx(self.searchBar.text!, page: page)
			.map { result in
//				print("got result for text \(self.searchBar.text!) and page \(page)")
				let searchResults = result["results"].arrayValue
				
				if page == 1 {
					self.results.removeAll()
					self.medatada.removeAll()
				}
				
				self.hasMoreResults = (result["page"] < result["total_pages"])
				
				let processedResults = searchResults
					.map { SearchResult(data: $0) }
					.filter { $0 != nil }
					.map { $0! }
				
				self.results.appendContentsOf(processedResults)
				self.medatada.appendContentsOf(searchResults)
			}
	}
	
	// MARK: reactive
	private func setupSearch() {
		
		// testing
		searchBar.text = "a"
		
		var currentPage: Int = 0
		
		let newSearch = searchBar.rx_text
			.throttle(0.5)
			.distinctUntilChanged()
			.flatMap {_ -> Observable<()> in
				currentPage = 1
				return self.newRequest(currentPage)
			}
			.share()
		
		let continueSearch = getNextPage
			.flatMap {_ -> Observable<()> in
				currentPage += 1
				return self.newRequest(currentPage)
			}
			.share()
		
		_ = Observable.of(newSearch, continueSearch)
			.merge()
			.subscribeError { error in
				print(error)
			}
	}
	
	private func setupActions() {
		
		_ = searchBar.rx_cancel
			.subscribeNext {
				self.searchBar.text = nil
				self.results.removeAll()
		}
		
		let rowSelect = tableView.rx_itemSelected.asObservable()
		
		_ = rowSelect
			.subscribeNext { indexPath in
				self.results.removeAll()
				
				let st = UIStoryboard(name: "NewMain", bundle: nil)
				let vc = st.instantiateViewControllerWithIdentifier("DetailsViewController") as! DetailsViewController
				let nc = UIApplication.sharedApplication().keyWindow!.rootViewController as! UINavigationController
				nc.pushViewController(vc, animated: true)
				
				let entity = Entity.createWithData(self.medatada[indexPath.row])
				vc.setupWithEntity(entity)
		}
		
		let drag = tableView.rx_delegate.observe(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)))
			.map { _ in }
		
		_ = Observable.of(	rowSelect.map { _ in },
							drag,
							searchBar.rx_cancel.asObservable())
			.merge()
			.filter {
				self.searchBar.isFirstResponder()
			}
			.subscribeNext {_ in
				self.searchBar.resignFirstResponder()
		}
	}
}
