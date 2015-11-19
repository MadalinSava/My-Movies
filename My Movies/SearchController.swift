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
	
	weak var delegate: SearchControllerDelegate?
	
	var searchBar: UISearchBar! = nil {
		didSet {
			searchBar.delegate = self
		}
	}
	
	private var block: dispatch_block_t! = nil
	private var currentPage = 0
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
				self.delegate?.resultsReset()
			} else {
				self.delegate?.resultsAdded(searchResults.count)
			}
			
			self.requestDone = true
		},
			error: { (error) in
				print(error.localizedDescription)
		})
	}
}

protocol SearchControllerDelegate: NSObjectProtocol {
	func resultsReset()
	func resultsAdded(count: Int)
}
