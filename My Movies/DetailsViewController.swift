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
	@IBOutlet var genresLabel: UILabel!
	@IBOutlet var watchlistButton: UIButton!
	@IBOutlet var posterImage: UIImageView!
	@IBOutlet var overviewLabel: UILabel!
	
	
	private var movie: Movie! = nil
	private var backdropImageAspectRatio: NSLayoutConstraint!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		titleLabel.text = "\(movie.title) (\(movie.releaseYear ?? "????"))"
		
		if let posterPath = movie.posterPath {
			ImageSetter.instance.setImage(posterPath, ofType: .Poster, andWidth: posterImage.frame.width, forView: posterImage, defaultImage: "default") { [unowned self] in
				let aspectRatio = self.posterImage.image!.size.height / self.posterImage.image!.size.width
				self.posterImage.addConstraint(NSLayoutConstraint(item: self.posterImage, attribute: .Height, relatedBy: .Equal, toItem: self.posterImage, attribute: .Width, multiplier: aspectRatio, constant: 0.0))
			}
		}
		
		updateWatchlistButton()
	}
	
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
	
	@IBAction func watchlistPressed() {
		if movie.toggleWatchList() {
			updateWatchlistButton()
		}
	}
	
	// MARK: private stuff
	private func setupUI() {
		gallery.setImages(movie.backdropPaths, ofType: .Backdrop)
		gallery.shouldStartSlideshow = true
		updateGalleryHeight()
		
		let separator = ", "
		let genreText = movie.genreList.reduce("") { (concatenated, genre) in
			return concatenated + genre + separator
		}
		genresLabel.text = (genreText~?)?[0, -separator.characters.count]
		
		overviewLabel.text = movie.overview
	}
	
	private func updateGalleryHeight() {
		if let minAR = movie.minBackdropAspectRatio {
			galleryHeight.constant = view.frame.width / CGFloat(minAR)
			gallery.resetLayout()
		} else {
			galleryHeight.constant = 0
		}
	}
	
	private func updateWatchlistButton() {
		let normalImage = movie.isInWatchList ? "bookmarkAddedNormal" : "bookmarkNormal"
		let selectedImage = movie.isInWatchList ? "bookmarkAddedPressed" : "bookmarkPressed"
		watchlistButton.setImage(UIImage(named: normalImage), forState: .Normal)
		watchlistButton.setImage(UIImage(named: selectedImage), forState: .Highlighted)
	}
}
