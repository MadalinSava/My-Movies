//
//  SecondViewController.swift
//  My Movies
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit
import RxSwift

class DetailsViewController: ScrollingViewController {
	

	@IBOutlet var gallery: GalleryView!
	@IBOutlet var galleryHeight: NSLayoutConstraint!
	
	@IBOutlet var posterViewHeight: NSLayoutConstraint!
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var genresLabel: UILabel!
	@IBOutlet var watchlistButton: UIButton!
	@IBOutlet var ratingView: Rating!
	
	@IBOutlet var posterImage: UIImageView!
	@IBOutlet var overviewLabel: UILabel!
	@IBOutlet var playTrailerButton: UIButton!
	
	private var fullscreenPoster: UIImageView!
	
	private var movie: Movie! = nil
	private var backdropImageAspectRatio: NSLayoutConstraint!
	
	private let bag = DisposeBag()
	
	deinit {
		print("finally")
	}

	// MARK: overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		playTrailerButton.rx_tap
		titleLabel.text = "\(movie.title) (\(movie.releaseYear ?? "????"))"
		
		if let posterPath = movie.posterPath {
			ImageSetter.instance.setImageRx(posterPath, ofType: .Poster, andWidth: posterImage.frame.width, forView: posterImage, defaultImage: "default")
				.subscribeCompleted { [weak self] in
					guard self != nil else {return}
					let aspectRatio = self!.posterImage.image!.size.height / self!.posterImage.image!.size.width
					self!.posterImage.addConstraint(NSLayoutConstraint(item: self!.posterImage, attribute: .Height, relatedBy: .Equal, toItem: self!.posterImage, attribute: .Width, multiplier: aspectRatio, constant: 0.0))
				}
				.addDisposableTo(bag)
		}
		
		updateWatchlistButton()
	}
	
	override func viewWillDisappear(animated: Bool) {
		gallery.stopSlideshow()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func shouldAutorotate() -> Bool {
		return fullscreenPoster == nil
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
	
	@IBAction func playTrailerPressed() {
		if let url = NSURL(string: "https://www.youtube.com/watch?v=\(movie.youtubeTrailer!)") {
			UIApplication.sharedApplication().openURL(url)
		}
	}
	
	@IBAction func overviewTapped(sender: UITapGestureRecognizer) {
		guard overviewLabel.isAllTextShown() == false || posterViewHeight.active == false else {
			return
		}
		
		!!posterViewHeight.active
		
		UIView.animateWithDuration(NSTimeInterval(UINavigationControllerHideShowBarDuration)) {
			// TODO: can make this more awesome
			self.view.layoutIfNeeded()
			//let overviewPosition = self.overviewLabel.convertPoint(self.overviewLabel.frame.origin, toView: self.view)
			//let overviewPositionInScrollview = self.overviewLabel.convertPoint(self.overviewLabel.frame.origin, toView: self.scrollView)
			//self.scrollView.contentOffset.y = overviewPositionInScrollview.y - self.topLayoutGuide.length
			// topLayoutGuide.length changes after scrolling, so set the content offset again according to the new value
			// TODO: solve the issue when it's not scrolling enough to hide the nav bar; it should scroll more
			//self.scrollView.contentOffset.y = overviewPositionInScrollview.y - self.topLayoutGuide.length
		}
	}
	
	@IBAction func posterTapped(sender: UITapGestureRecognizer) {
		if sender.view == posterImage {
			showFullscreenPoster(sender)
		} else {
			hideFullscreenPoster(sender)
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
		
		if movie.youtubeTrailer != nil {
			playTrailerButton.enabled = true
		}
		
		ratingView.score = movie.rating
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
	
	private func showFullscreenPoster(gestureRecognizer: UITapGestureRecognizer) {
		if UIDevice.currentDevice().orientation.isLandscape {
			UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
		}
		// TODO: keep the image in memory? it can be purged on memory warning; it can also be initialized on load with a higher resolution poster, but it needs to be exactly the same; otherwise, maybe use a high res poster for the small image
		fullscreenPoster = UIImageView(image: posterImage.image)
		_ = ImageSetter.instance.setImageRx(movie.posterPath, ofType: .Poster, andWidth: view.frame.width, forView: fullscreenPoster)
			.subscribe()
		
		let viewToAdd = UIApplication.sharedApplication().delegate!.window!!
		
		var initialFrame = posterImage.frame
		initialFrame.origin = posterImage.convertPoint(posterImage.frame.origin, toView: viewToAdd)
		fullscreenPoster.frame = initialFrame
		
		fullscreenPoster.contentMode = .ScaleAspectFit
		fullscreenPoster.userInteractionEnabled = true
		fullscreenPoster.addGestureRecognizer(gestureRecognizer)
		viewToAdd.addSubview(fullscreenPoster)
		
		UIView.animateWithDuration(0.3, animations: {
			self.fullscreenPoster.frame = viewToAdd.frame
			}, completion: { (completed) in
				UIView.animateWithDuration(0.2, delay: 0.1, options: .CurveEaseInOut, animations: {
					self.fullscreenPoster.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
					}, completion: nil)
		})
	}
	
	private func hideFullscreenPoster(gestureRecognizer: UITapGestureRecognizer) {
		posterImage.addGestureRecognizer(gestureRecognizer)
		
		var oldFrame = posterImage.frame
		oldFrame.origin = posterImage.convertPoint(posterImage.frame.origin, toView: UIApplication.sharedApplication().delegate!.window!!)
		fullscreenPoster.backgroundColor = UIColor.clearColor()
		UIView.animateWithDuration(0.3, animations: {
			self.fullscreenPoster.frame = oldFrame
			}, completion: { _ in
				self.fullscreenPoster.removeFromSuperview()
				self.fullscreenPoster = nil
		})
	}
}
