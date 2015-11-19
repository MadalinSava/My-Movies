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
	//@IBOutlet var title: UINavigationItem!
	
	/*@IBAction func backPressed(sender: UIBarButtonItem) {
		
	}*/
	
	var movie: Movie!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		//overviewLabel.addGestureRecognizer(UIGestureRecognizer(target: self, action: "stuff")
	}
	
	@IBAction func overviewTapped(sender: UITapGestureRecognizer) {
		let heightConstraint = self.constraints[self.constraints.indexOf { (constraint) in
			return constraint.identifier == "posterHeight"
			}!]
		
		//dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2)), dispatch_get_main_queue()) { [unowned self] () -> Void in
			UIView.animateWithDuration(0.3) { [unowned self] () -> Void in
				heightConstraint.priority = 749 + 751 - heightConstraint.priority
				self.layoutIfNeeded()
			}
		//}
	}
	
	private func stuff() {
		
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
		
		runTimeLabel.text = movie.runTime?.description +? "min"
		
		var genreText: String? = movie.genreList.reduce("") { (concatenated, genre) in
			return concatenated! + genre + " "
		}
		genreText = (genreText~?)?.substringToIndex(genreText!.endIndex.predecessor())
		genresLabel.text = genreText
	}
}
