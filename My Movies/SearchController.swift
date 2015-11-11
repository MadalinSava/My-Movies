//
//  SearchController.swift
//  My Movies
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class SearchController: NSObject, UISearchBarDelegate {
	
	private(set) var results: [SearchResult] = [SearchResult]()
	private(set) var medatada = [JSON]()
	private(set) var hasMoreResults = false
	
	var delegate: SearchControllerDelegate?
	
	var searchBar: UISearchBar! = nil {
		didSet {
			searchBar.delegate = self
		}
	}
	
	private var block: dispatch_block_t! = nil
	private var currentPage = 1
	private var requestDone = true
	/*
	required override init() {
		super.init()
	}
	*/
	
	func getResultsForNextPage() {
		guard requestDone else {
			return
		}
		++currentPage
		doRequest()
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
		delegate?.resultsReset()
	}
	
	// MARK: request
	private func doRequest() {
		//print("requesting page \(currentPage)")
		self.requestDone = false
		
		Api.instance.searchMulti(searchBar.text!, page: currentPage){ [unowned self] (resp, data, error) -> Void in
			
			guard error == nil else {
				print(error!.localizedDescription)
				self.requestDone = true
				return
			}
			//print(NSString(data: data!, encoding: NSUTF8StringEncoding))
			let jsonObject = JSON(data: data!)
			let results = jsonObject["results"]
			//if results.count == 0 {
			//	print(jsonObject)
			//}
			if self.currentPage == 1 {
				self.results.removeAll()
				self.medatada.removeAll()
			}
			for var i = 0; i < results.count; ++i {
				if let newResult = SearchResult(data: results[i]) {
					self.results.append(newResult)
					self.medatada.append(results[i])
					//print("result: \(newResult.name)")
				}
			}
			self.hasMoreResults = (jsonObject["page"] < jsonObject["total_pages"])
			if self.currentPage == 1 {
				self.delegate?.resultsReset()
			} else {
				self.delegate?.resultsAdded(results.count)
			}
			self.requestDone = true
		}
	}
}

protocol SearchControllerDelegate {
	func resultsReset()
	func resultsAdded(count: Int)
}
