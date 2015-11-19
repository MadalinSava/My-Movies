//
//  SecondViewController.swift
//  My Movies
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
	
	//var metadata: JSON! = nil
	@IBOutlet var navBar: UINavigationBar!
	@IBOutlet var navBarTitle: UINavigationItem!
	@IBOutlet var barItem: UITabBarItem!
	//@IBOutlet var posterImage: UIImageView!
	
	private var barItemImageSize: CGSize!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tabBarItem!.enabled = true
		barItemImageSize = barItem.selectedImage!.size
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func setupWithData(data: JSON, image: UIImage) {
		
		var nibName: String
		switch data["media_type"] {
		case "movie":
			nibName = "MovieDetails"
		case "person":
			nibName = "PersonDetails"
		case "tv":
			nibName = "SeriesDetails"
		default:
			return
		}
		
		let detailsView = NSBundle.mainBundle().loadNibNamed(nibName, owner: self, options: nil)[0] as! DetailsView
		detailsView.setupWithMovie(Movie(data: data))
		
		// setup frame
		var frame = view.frame
		frame.size.height -= topLayoutGuide.length + bottomLayoutGuide.length + navBar.frame.height
		frame.origin.y += topLayoutGuide.length + navBar.frame.height
		detailsView.frame = frame
		
		//detailsView.metadata = data
		navBarTitle.title = detailsView.getTitle()
		
		view.addSubview(detailsView)
		//detailsView.setNeedsLayout()
		
		// set tab bar button images
		barItem.image = getNormalBarItemImageFromImage(image)
		let tintColor = (parentViewController as! UITabBarController).tabBar.tintColor.colorWithAlphaComponent(0.2)
		barItem.selectedImage = getNormalBarItemImageFromImage(image, withTintColor: tintColor)
		
		// TESTING
		/*let posterPath = data["poster_path"].stringValue
		posterImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: "https://image.tmdb.org/t/p/w300" + posterPath)!)!)*/
	}
	
	@IBAction func backPressed(sender: UIBarButtonItem) {
		(self.parentViewController as! TabBarController).selectedIndex = 0
	}
	
	private func getNormalBarItemImageFromImage(image: UIImage, withTintColor color: UIColor = .clearColor()) -> UIImage {
		let scale = max(image.size.width / barItemImageSize.width, image.size.height / barItemImageSize.height)
		let newSize = CGSize(width: image.size.width / scale, height: image.size.height / scale)
		UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
		let drawRect = CGRect(x: 0.0, y: 0.0, width: newSize.width, height: newSize.height)
		image.drawInRect(drawRect)
		color.set()
		UIRectFillUsingBlendMode(drawRect, .Normal)
		let newImage = UIGraphicsGetImageFromCurrentImageContext().imageWithRenderingMode(.AlwaysOriginal)
		UIGraphicsEndImageContext()
		return newImage
	}
}

