//
//  SecondViewController.swift
//  My Movies
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

typealias ActionBlock = () -> Void

class DetailsViewController: ScrollingViewController {
	

	@IBOutlet var gallery: GalleryView!
	@IBOutlet var galleryHeight: NSLayoutConstraint!
	
	@IBOutlet var titleLabel: UILabel!
	
	private var movie: Movie! = nil
	private var backdropImageAspectRatio: NSLayoutConstraint!

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func didAutorotate() {
		super.didAutorotate()
		
		updateGalleryHeight()
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
	
	// MARK: private stuff
	private func setupUI() {
		gallery.setImages(movie.backdropPaths, ofType: .Backdrop)
		updateGalleryHeight()
		
		titleLabel.text = movie.title
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
