//
//  NavigationController.swift
//  My Movies
//
//  Created by Madalin Sava on 24/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
	
	@IBOutlet var navigationView: UIView!
	@IBOutlet var searchBar: UISearchBar!
	
	
	@IBOutlet var backButton: UIButton!
	
	@IBOutlet var backToSearch: NSLayoutConstraint!
	@IBOutlet var marginToSearch: NSLayoutConstraint!
	@IBOutlet var marginToBack: NSLayoutConstraint!
	@IBOutlet var leadingToBack: NSLayoutConstraint!
	
	private var controllerAnimationDuration: Double! = nil
	
	override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
		if viewControllers.count == 2 {
			hideBackButton(animated)
		}
		
		//topViewController!.navigationItem.hidesBackButton = true
		let lastVC = super.popViewControllerAnimated(animated)
		//lastVC!.navigationItem.hidesBackButton = true
		
		print(navigationBar.subviews)
		let left = navigationBar.backItem
		
		return lastVC
	}
	
	override func pushViewController(viewController: UIViewController, animated: Bool) {
		
		//self.view.an
		//viewController.navigationItem.hidesBackButton = true
		super.pushViewController(viewController, animated: animated)
		if controllerAnimationDuration == nil {
			controllerAnimationDuration = topViewController!.transitionCoordinator()!.transitionDuration()
		}
		if viewControllers.count == 2 {
			showBackButton(animated)
		}
		
		//let duration = viewController.transitionCoordinator()!.transitionDuration()
		//print(duration)
		let left = navigationBar.backItem
	}
	
	/*override func animationDidStart(anim: CAAnimation) {
		super.animationDidStart(anim)
	}
	
	override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
		super.animationDidStop(anim, finished: flag)
	}*/
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		navigationItem.setHidesBackButton(true, animated: false)
		
		for subView in searchBar.subviews  {
			//print(subView.backgroundColor)
			subView.backgroundColor = UIColor.clearColor()
			subView.opaque = false
			//subView.alpha = 0.0
			for subsubView in subView.subviews  {
				if let _ = subsubView as? UITextField {
				}
				else {
					subsubView.backgroundColor = UIColor.clearColor()
					subsubView.opaque = false
					subsubView.alpha = 0.0
					//print(subsubView)
				}
			}
		}
		
		navigationView.frame = navigationBar.frame
		navigationBar.addSubview(navigationView)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		navigationItem.hidesBackButton = true
		hideBackButton(false)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		//navigationView.layoutIfNeeded()
	}
	
	@IBAction func backButtonPressed(sender: UIButton) {
		popViewControllerAnimated(true)
	}
	
	private func animateNavigationView() {
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
}
