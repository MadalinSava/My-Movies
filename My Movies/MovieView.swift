//
//  MovieView.swift
//  My Movies
//
//  Created by Madalin Sava on 11/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit
//import AVKit

class MovieView: DetailsView {
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var yearLabel: UILabel!
	@IBOutlet var runTimeLabel: UILabel!
	@IBOutlet var posterImage: UIImageView!
	@IBOutlet var overviewLabel: UILabel!
	@IBOutlet var playTrailerButton: UIButton!
	@IBOutlet var whishlistButton: UIButton!
	
	@IBOutlet var genresLabel: UILabel!
	@IBOutlet var posterHeightConstraint: NSLayoutConstraint!
	
	private var movie: Movie!
	
	// animation stuff
	private var originalPosterHeightConstraintPriority: UILayoutPriority! = nil
	private var expandedPosterHeightConstraintPriority: UILayoutPriority = 749
	
	private var animationPosterImageFrame: CGRect! = nil
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		originalPosterHeightConstraintPriority = posterHeightConstraint.priority
	}
	
	@IBAction func overviewTapped(sender: UITapGestureRecognizer) {
		animateOverviewLabel()
	}
	
	@IBAction func posterTapped(sender: UITapGestureRecognizer) {
		if sender.view == posterImage {
			showFullscreenPoster(sender)
		} else {
			hideFullscreenPoster(sender)
		}
	}
	
	override func setupWithMovie(movie: Movie) {
		
		titleLabel.text = movie.title
		
		Api.instance.requestMovieDetails(movie.id, success: gotDetails)
		
		overviewLabel.text = movie.overview
		
		if let posterPath = movie.posterPath {
			// TODO: image setter
			posterImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: "https://image.tmdb.org/t/p/w300" + posterPath)!)!)
			// TODO: default poster
			let aspectRatio = posterImage.image!.size.height / posterImage.image!.size.width
			posterImage.addConstraint(NSLayoutConstraint(item: posterImage, attribute: .Height, relatedBy: .Equal, toItem: posterImage, attribute: .Width, multiplier: aspectRatio, constant: 0.0))
		}
		
		yearLabel.text = "(" +? movie.releaseYear +? ")"
		
		self.movie = movie
	}
	
	override func getTitle() -> String {
		return "Movie Details"
	}
	
	@IBAction func trailerPressed(sender: UIButton) {
		if let url = NSURL(string: "https://www.youtube.com/watch?v=\(movie.youtubeTrailer!)") {
			UIApplication.sharedApplication().openURL(url)
		}
	}
	
	@IBAction func whishlistPressed(sender: UIButton) {
		print("whishlist pressed")
	}
	
	private func gotDetails(result: JSON) {
		
		movie.addData(result)
		
		if movie.youtubeTrailer != nil {
			playTrailerButton.enabled = true
		}
		
		runTimeLabel.text = movie.runTime?.description +? " min"
		
		let genreText: String = movie.genreList.reduce("") { (concatenated, genre) in
			return concatenated + genre + " "
		}
		genresLabel.text = (genreText~?)?.substringToIndex(genreText.endIndex.predecessor())
	}
	
	// MARK: animations
	private func animateOverviewLabel() {
		if posterHeightConstraint.priority == originalPosterHeightConstraintPriority {
			posterHeightConstraint.priority = expandedPosterHeightConstraintPriority
		} else {
			posterHeightConstraint.priority = originalPosterHeightConstraintPriority
		}
		
		UIView.animateWithDuration(0.3) { [unowned self] () -> Void in
			self.layoutIfNeeded()
		}
	}
	
	private func showFullscreenPoster(gestureRecognizer: UITapGestureRecognizer) {
		// expand
		
		// TODO: keep the image in memory? it can be purged on memory warning; it can also be initialized on load with a higher resolution poster, but it needs to be exactly the same; otherwise, maybe use a high res poster for the small image
		let bigImage = UIImageView(image: posterImage.image)
		
		let containingView = superview!
		
		animationPosterImageFrame = posterImage.frame
		let offset = containingView.convertPoint(animationPosterImageFrame.origin, toView: posterImage)
		animationPosterImageFrame.origin.x -= offset.x
		animationPosterImageFrame.origin.y -= offset.y
		bigImage.frame = animationPosterImageFrame
		
		bigImage.contentMode = .ScaleAspectFit
		bigImage.userInteractionEnabled = true
		bigImage.addGestureRecognizer(gestureRecognizer)
		UIApplication.sharedApplication().delegate!.window!!.rootViewController!.view!.addSubview(bigImage)
		
		UIView.animateWithDuration(0.3, animations: { [unowned self] in
			//bigImage.frame = self.frame
			bigImage.frame = UIScreen.mainScreen().bounds
			}, completion: { (completed) in
				UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveLinear, animations: { [unowned self] in
				bigImage.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
				}, completion: nil)
		})
	}
	
	private func hideFullscreenPoster(gestureRecognizer: UITapGestureRecognizer) {
		// shrink
		let bigImage = gestureRecognizer.view!
		posterImage.addGestureRecognizer(gestureRecognizer)
		
		bigImage.backgroundColor = UIColor.clearColor()
		UIView.animateWithDuration(0.3, animations: { [unowned self] in
			bigImage.frame = self.animationPosterImageFrame
			}, completion: { (_) in
				bigImage.removeFromSuperview()
		})
	}
}
