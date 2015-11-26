//
//  FirstViewController.swift
//  My Movies
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
	
	
	@IBOutlet var topSearchbar: UISearchBar!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		//let searchBar = (navigationController as! NavigationController).searchBar
		//navigationItem.titleView = searchBar
		
		//navigationItem.backBarButtonItem = UIBarButtonItem(title: "Beac", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
		
		//navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Home"), style: UIBarButtonItemStyle.Plain, target: self, action: "popViewControllerAnimated")
		
		
		let navBar = navigationController!.navigationBar
		
		//navigationItem. = parentViewController!.navigationItem
		
		//navigationBar.addSubview(searchBar)
		
		//navigationItem.titleView = parentViewController!.navigationItem.titleView
		//navigationItem.rightBarButtonItem = UIBarButtonItem(customView: parentViewController!.navigationItem.titleView!)
		//navigationItem.rightBarButtonItem = UIBarButtonItem(customView: topSearchbar)
		//print(navigationItem.leftBarButtonItem?.image)
		//print(navigationItem.leftBarButtonItem?.customView)
		//print(navigationItem.rightBarButtonItem?.customView)
		//let constraint = NSLayoutConstraint(item: navigationItem.rightBarButtonItem!.customView!, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: navigationItem.leftBarButtonItem!.image!, attribute: NSLayoutAttribute.Right, multiplier: 0.0, constant: 0.0)
		/*searchController.searchBar = topSearchbar
		searchController.delegate = self*/
		//title = "wow"
		
		/*searchController.searchBar = searchBar
		searchController.delegate = self
		
		tableView.hidden = true
		
		searchBar.text = "matrix"//"fight bat"
		searchController.getResultsForNextPage()
		
		tableView.registerNib(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: SearchCell.reuseIdentifier)*/
		//ImageSetter.instance
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		print("home: \(topLayoutGuide.length)")
	}
	
	override func viewDidAppear(animated: Bool) {
		
		print("home: \(topLayoutGuide.length)")
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

