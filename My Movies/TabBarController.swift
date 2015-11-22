//
//  TabBarController.swift
//  My Movies
//
//  Created by Madalin Sava on 11/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
	
	private var prevTabIndex = -1
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		for (index, vc) in viewControllers!.enumerate() {
			if let v = vc as? TabbedViewController {
				v.dynamicType.tabIndex = index
			}
		}
	}
	/*
	override func viewWillAppear(animated: Bool) {
		print(selectedIndex)
		//selectedIndex = 2
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		print(segue, sender, separator: "|||", terminator: "\n")
	}
	
	override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
		print("Asd")
	}*/
	
	override func showViewController(vc: UIViewController, sender: AnyObject?) {
		print("asd")
	}
	
	override func showDetailViewController(vc: UIViewController, sender: AnyObject?) {
		super.showDetailViewController(vc, sender: sender)
	}
	
	func goToDetails() -> DetailsViewController {
		prevTabIndex = selectedIndex
		selectedIndex = DetailsViewController.tabIndex
		
		//showDetailViewController(viewControllers![DetailsViewController.tabIndex], sender: nil)
		
		return selectedViewController as! DetailsViewController
	}
	
	func goBack() {
		selectedIndex = prevTabIndex
	}
}
