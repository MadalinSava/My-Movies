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
	

	@IBOutlet var gallery: GalleryView!
	
	@IBOutlet var galleryHeight: NSLayoutConstraint!
	
	
	private var movie: Movie! = nil
	private var backdropImageAspectRatio: NSLayoutConstraint!
	
	
	private var lastScrollPosition: CGFloat = 0.0
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
		guard didAppear else {
			lastScrollPosition = scrollView.contentOffset.y
			return
		}
		let delta = topLayoutGuide.length
		if scrollView.contentOffset.y - lastScrollPosition > delta {
			navigationController!.setNavigationBarHidden(true, animated: true)
			lastScrollPosition = scrollView.contentOffset.y
		} else if scrollView.contentOffset.y - lastScrollPosition < -delta {
			navigationController!.setNavigationBarHidden(false, animated: true)
			lastScrollPosition = scrollView.contentOffset.y
		}
	}
	
	// MARK: private stuff
	private func setupUI() {
		if let minAR = movie.minBackdropAspectRatio {
			galleryHeight.constant = view.frame.width / CGFloat(minAR)
			gallery.setImages(movie.backdropPaths, ofType: .Backdrop)
		} else {
			galleryHeight.constant = 0
		}
	}
}

