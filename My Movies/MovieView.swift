//
//  MovieView.swift
//  My Movies
//
//  Created by Madalin Sava on 11/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class MovieView: DetailsView {
	
	override class var nibName: String {
		return "MovieDetails"
	}
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var yearLabel: UILabel!
	@IBOutlet var runTimeLabel: UILabel!
	@IBOutlet var posterImage: UIImageView!
	
	@IBOutlet var overviewScroll: UIScrollView!
	@IBOutlet var overviewLabel: UILabel!
	@IBOutlet var playTrailerButton: UIButton!
	
	@IBOutlet var watchlistButton: UIButton!
	
	@IBOutlet var genresLabel: UILabel!
	
	private var movie: Movie!
	
	// animation stuff
	@IBOutlet var posterHeightConstraint: NSLayoutConstraint!
	@IBOutlet var bottomScrollConstraint: NSLayoutConstraint!
	@IBOutlet var scrollHeightConstraint: NSLayoutConstraint!
    private var expandedScrollHeightConstraint: NSLayoutConstraint!
	
	private var animationPosterImageFrame: CGRect! = nil
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		bottomScrollConstraint.active = false
	}
	
	@IBAction func overviewTapped(sender: UITapGestureRecognizer) {
        if animateOverviewLabel() == false {
            sender.view!.removeGestureRecognizer(sender)
        }
	}
	
	@IBAction func posterTapped(sender: UITapGestureRecognizer) {
		if sender.view == posterImage {
			showFullscreenPoster(sender)
		} else {
			hideFullscreenPoster(sender)
		}
	}
	
	override func setupWithEntity(entity: Entity) {
		movie = entity as! Movie
		
		// setup only the UI that is sure to have the metadata here
		titleLabel.text = movie.title
		
		if let posterPath = movie.posterPath {
			ImageSetter.instance.setImage(posterPath, ofType: .Poster, andWidth: posterImage.frame.width, forView: posterImage, defaultImage: "default") { [unowned self] in
				let aspectRatio = self.posterImage.image!.size.height / self.posterImage.image!.size.width
				self.posterImage.addConstraint(NSLayoutConstraint(item: self.posterImage, attribute: .Height, relatedBy: .Equal, toItem: self.posterImage, attribute: .Width, multiplier: aspectRatio, constant: 0.0))
			}
		}
		
		setWatchListButtonImage()
		
		setupUI()
		
		Api.instance.requestMovieDetails(movie.id, success: gotDetails)
	}
	
	override func getTitle() -> String {
		return "Movie Details"
	}
	
	@IBAction func trailerPressed(sender: UIButton) {
		if let url = NSURL(string: "https://www.youtube.com/watch?v=\(movie.youtubeTrailer!)") {
			UIApplication.sharedApplication().openURL(url)
		}
	}
	
	@IBAction func watchlistPressed(sender: UIButton) {
		if movie.toggleWatchList() {
			setWatchListButtonImage()
		} else {
			print("core data error")
		}
	}
	
	private func gotDetails(result: JSON) {
		
		movie.addData(result)
		
		setupUI()
	}
	
	private func setupUI() {
		
		overviewLabel.text = movie.overview
		
		yearLabel.text = "(" +? movie.releaseYear +? ")"
		
		if movie.youtubeTrailer != nil {
			playTrailerButton.enabled = true
		}
		
		runTimeLabel.text = movie.runTime?.description +? " min"
		
		let genreText: String = movie.genreList.reduce("") { (concatenated, genre) in
			return concatenated + genre + " "
		}
		genresLabel.text = (genreText~?)?.substringToIndex(genreText.endIndex.predecessor())
	}
	
	private func setWatchListButtonImage() {
		if movie.isInWatchList {
			watchlistButton.setImage(UIImage(named: "Home"), forState: .Normal)
		} else {
			watchlistButton.setImage(UIImage(named: "second"), forState: .Normal)
		}
	}
	
	// MARK: animations
	private func animateOverviewLabel() -> Bool {
		!!scrollHeightConstraint.active
		!!posterHeightConstraint.active
        
        if expandedScrollHeightConstraint == nil {
            layoutIfNeeded()
            
            if overviewLabel.frame.height <= overviewScroll.frame.height {
                !!scrollHeightConstraint.active
                !!posterHeightConstraint.active
                return false
            }
            
            let labelFrameInView = overviewLabel.convertPoint(overviewLabel.frame.origin, toView: self)
            let bottomDist = frame.height - labelFrameInView.y
            let height = min(overviewLabel.frame.height, bottomDist)
            
            expandedScrollHeightConstraint = NSLayoutConstraint(item: overviewScroll, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: height)
            overviewScroll.addConstraint(expandedScrollHeightConstraint)
        } else {
            !!expandedScrollHeightConstraint.active
        }
        
        UIView.animateWithDuration(0.3) { [unowned self] () -> Void in
            self.layoutIfNeeded()
        }
        
        return true
	}
	
	private func showFullscreenPoster(gestureRecognizer: UITapGestureRecognizer) {
		// TODO: keep the image in memory? it can be purged on memory warning; it can also be initialized on load with a higher resolution poster, but it needs to be exactly the same; otherwise, maybe use a high res poster for the small image
		let bigImage = UIImageView(image: posterImage.image)
		ImageSetter.instance.setImage(movie.posterPath, ofType: .Poster, andWidth: frame.width, forView: bigImage)
		
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
			bigImage.frame = UIScreen.mainScreen().bounds
			}, completion: { (completed) in
				UIView.animateWithDuration(0.2, delay: 0.1, options: .CurveLinear, animations: { [unowned self] in
				bigImage.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
				}, completion: nil)
		})
	}
	
	private func hideFullscreenPoster(gestureRecognizer: UITapGestureRecognizer) {
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
