//
//  ScrollingViewController.swift
//  My Movies
//
//  Created by Madalin Sava on 27/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class ScrollingViewController: CustomViewController, UIScrollViewDelegate {
	
	@IBOutlet var scrollView: UIScrollView!
	
	private var topBarToggleScrollDelta: CGFloat = 0
	private var lastScrollPosition: CGFloat = CGFloat.NaN
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
			navigationController!.setNavigationBarHidden(true, animated: false)
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		topBarToggleScrollDelta = topLayoutGuide.length
	}
	
	override func didAutorotate() {
		let hideNavBar = UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)
		navigationController!.setNavigationBarHidden(hideNavBar, animated: false)
		topBarToggleScrollDelta = topLayoutGuide.length
	}
	
	// MARK: UIScrollViewDelegate
	func scrollViewDidScroll(scrollView: UIScrollView) {
		guard let navigationController = navigationController as? NavigationController else {
			return
		}
		
		navigationController.searchBar.resignFirstResponder()
		
		guard didAppear && lastScrollPosition != CGFloat.NaN && UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) else {
			// TODO: check orientation unknown bug on device
			lastScrollPosition = scrollView.contentOffset.y
			return
		}
		
		if scrollView.contentOffset.y < lastScrollPosition {
			if navigationController.navigationBarHidden == false {
				lastScrollPosition = scrollView.contentOffset.y
			}
		} else {
			if navigationController.navigationBarHidden {
				lastScrollPosition = scrollView.contentOffset.y
			}
		}
		
		// TODO: check animation smoothness on device
		if navigationController.navigationBarHidden == false && scrollView.contentOffset.y - lastScrollPosition > topBarToggleScrollDelta && scrollView.contentOffset.y >= topBarToggleScrollDelta {
			UIView.animateWithDuration(NSTimeInterval(UINavigationControllerHideShowBarDuration)) { [unowned self] in
				self.navigationController!.setNavigationBarHidden(true, animated: true)
				scrollView.contentOffset.y -= self.topBarToggleScrollDelta - self.topLayoutGuide.length
				self.view.layoutIfNeeded()
			}
			lastScrollPosition = scrollView.contentOffset.y
		} else if navigationController.navigationBarHidden && scrollView.contentOffset.y - lastScrollPosition < -topBarToggleScrollDelta {
			UIView.animateWithDuration(NSTimeInterval(UINavigationControllerHideShowBarDuration)) { [unowned self] in
				scrollView.contentOffset.y += self.topBarToggleScrollDelta - self.topLayoutGuide.length
				self.navigationController!.setNavigationBarHidden(false, animated: false)
				self.view.layoutIfNeeded()
			}
			lastScrollPosition = scrollView.contentOffset.y
		}
	}
}
