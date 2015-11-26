//
//  SecondViewController.swift
//  My Movies
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

typealias ActionBlock = () -> Void

class DetailsViewController: CustomViewController, UIScrollViewDelegate {
	

	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var gallery: GalleryView!
	
	@IBOutlet var galleryHeight: NSLayoutConstraint!
	
	
	private var movie: Movie! = nil
	private var backdropImageAspectRatio: NSLayoutConstraint!
	
	private var topBarToggleScrollDelta: CGFloat = 0
	private var lastScrollPosition: CGFloat = CGFloat.NaN
	
	deinit {
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
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
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func didAutorotate() {
		let hideNavBar = UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)
		navigationController!.setNavigationBarHidden(hideNavBar, animated: false)
		topBarToggleScrollDelta = topLayoutGuide.length
		
		updateGalleryHeight()
		lastScrollPosition = scrollView.contentOffset.y
	}
	
	func setupWithEntity(entity: Entity) {
		
		movie = entity as! Movie
		
		movie.requestDetails(setupUI)
		
		//var asd = MovieView.Type
		/*var classType: DetailsView.Type
		switch entity {
		case is Movie:
			classType = MovieView.self
		case is Series:
			classType = SeriesView.self
		case is Person:
			classType = PersonView.self
		default:
			return
		}*/
		
		//detailsView?.removeFromSuperview()
		//detailsView = NSBundle.mainBundle().loadNibNamed(classType.nibName, owner: self, options: nil)[0] as! DetailsView
		
		// setup frame
		
		//print("details: \(topLayoutGuide.length)")
		/*var frame = view.frame
		frame.size.height -= topLayoutGuide.length + bottomLayoutGuide.length// + navBar.frame.height
		frame.origin.y += topLayoutGuide.length// + navBar.frame.height
		detailsView.frame = frame
		
		view.addSubview(detailsView)
		
		detailsView.setupWithEntity(entity)*/
		
		//navBarTitle.title = detailsView.getTitle()
	}
	
	// MARK: UIScrollViewDelegate
	func scrollViewDidScroll(scrollView: UIScrollView) {
		guard didAppear && lastScrollPosition != CGFloat.NaN && UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) else {
			// TODO: check orientation unknown bug on device
			lastScrollPosition = scrollView.contentOffset.y
			return
		}
		
		if scrollView.contentOffset.y < lastScrollPosition {
			if navigationController!.navigationBarHidden == false {
				lastScrollPosition = scrollView.contentOffset.y
			}
		} else {
			if navigationController!.navigationBarHidden {
				lastScrollPosition = scrollView.contentOffset.y
			}
		}
		
		// TODO: check animation smoothness on device
		if navigationController!.navigationBarHidden == false && scrollView.contentOffset.y - lastScrollPosition > topBarToggleScrollDelta && scrollView.contentOffset.y >= topBarToggleScrollDelta {
			UIView.animateWithDuration(NSTimeInterval(UINavigationControllerHideShowBarDuration)) { [unowned self] in
				self.navigationController!.setNavigationBarHidden(true, animated: true)
				scrollView.contentOffset.y -= self.topBarToggleScrollDelta - self.topLayoutGuide.length
				self.view.layoutIfNeeded()
			}
			lastScrollPosition = scrollView.contentOffset.y
		} else if navigationController!.navigationBarHidden && scrollView.contentOffset.y - lastScrollPosition < -topBarToggleScrollDelta {
			UIView.animateWithDuration(NSTimeInterval(UINavigationControllerHideShowBarDuration)) { [unowned self] in
				scrollView.contentOffset.y += self.topBarToggleScrollDelta - self.topLayoutGuide.length
				self.navigationController!.setNavigationBarHidden(false, animated: false)
				self.view.layoutIfNeeded()
			}
			lastScrollPosition = scrollView.contentOffset.y
		}
	}
	
	// MARK: private stuff
	private func setupUI() {
		gallery.setImages(movie.backdropPaths, ofType: .Backdrop)
		updateGalleryHeight()
	}
	
	private func updateGalleryHeight() {
		if let minAR = movie.minBackdropAspectRatio {
			galleryHeight.constant = view.frame.width / CGFloat(minAR)
			gallery.resetLayout()
		} else {
			galleryHeight.constant = 0
		}
	}
}
