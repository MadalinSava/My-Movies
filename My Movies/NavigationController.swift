//
//  NavigationController.swift
//  My Movies
//
//  Created by Madalin Sava on 24/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UINavigationControllerDelegate {
	
	@IBOutlet var navigationView: UIView!
	@IBOutlet var searchBar: UISearchBar!
	
	@IBOutlet var searchTable: UITableView!
	
	@IBOutlet var backButton: UIButton!
	
	@IBOutlet var backToSearch: NSLayoutConstraint!
	@IBOutlet var marginToSearch: NSLayoutConstraint!
	@IBOutlet var marginToBack: NSLayoutConstraint!
	@IBOutlet var leadingToBack: NSLayoutConstraint!
	
	private var searchController: SearchController!
	private var controllerAnimationDuration: Double! = nil
	/*
	func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
		
		//searchController.addToViewController(topViewController!)
	}*/
	
	func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
		
		searchController.addToViewController(topViewController!)
		
		// for tests
		/*if viewControllers.count == 1 {
			searchBar.text = "matrix"
			searchController.results.removeAll()
			searchTable
			searchController.getResultsForNextPage()
		}*/
	}
	
	// MARK: overrides
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		delegate = self
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		correctSearchBarColor()
		
		navigationView.frame = navigationBar.frame
		navigationBar.addSubview(navigationView)
		
		searchController = SearchController(searchBar: searchBar, tableView: searchTable)
		
		// for tests
		searchBar.text = "godfather"//"matrix"
		searchController.getResultsForNextPage()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		hideBackButton(false)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func pushViewController(viewController: UIViewController, animated: Bool) {
		
		// hack for back label bug
		topViewController!.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
		viewController.navigationItem.hidesBackButton = true
		
		super.pushViewController(viewController, animated: animated)
		
		if viewControllers.count == 2 {
			showBackButton(animated)
		}
	}
	
	override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
		if viewControllers.count == 2 {
			hideBackButton(animated)
		}
		
		return super.popViewControllerAnimated(animated)
	}
	
	override func setNavigationBarHidden(hidden: Bool, animated: Bool) {
		super.setNavigationBarHidden(hidden, animated: animated)
		if hidden == false {
			hideBackButton(false)
			showBackButton(false)
		}
	}
	
	@IBAction func backButtonPressed(sender: UIButton) {
		popViewControllerAnimated(true)
	}
	
	// MARK: UI stuff
	private func animateNavigationView() {
		if controllerAnimationDuration == nil {
			controllerAnimationDuration = topViewController!.transitionCoordinator()!.transitionDuration()
		}
		UIView.animateWithDuration(controllerAnimationDuration) { [unowned self] in
			self.navigationView.layoutIfNeeded()
		}
	}
	
	private func showBackButton(animated: Bool) {
		!!leadingToBack.active
		!!marginToSearch.active
		!!backToSearch.active
		!!marginToBack.active
		
		if animated {
			animateNavigationView()
		}
	}
	
	private func hideBackButton(animated: Bool) {
		backToSearch.active = false
		marginToBack.active = false
		leadingToBack.active = true
		marginToSearch.active = true
		
		if animated {
			animateNavigationView()
		}
	}
	
	private func correctSearchBarColor() {
		for subView in searchBar.subviews  {
			subView.backgroundColor = UIColor.clearColor()
			subView.opaque = false
			for subsubView in subView.subviews  {
				if subsubView as? UITextField == nil {
					subsubView.backgroundColor = UIColor.clearColor()
					subsubView.opaque = false
					subsubView.alpha = 0.0
				}
			}
		}
	}
}
