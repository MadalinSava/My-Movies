//
//  SecondViewController.swift
//  My Movies
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, TabbedViewController {
	
	static var tabIndex = -1
	
	@IBOutlet var navBar: UINavigationBar!
	@IBOutlet var navBarTitle: UINavigationItem!
	@IBOutlet var barItem: UITabBarItem!
	
	private var detailsView: DetailsView! = nil
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
	
	func setupWithEntity(entity: Entity, andImage image: UIImage) {
		//var asd = MovieView.Type
		var classType: DetailsView.Type
		switch entity {
		case is Movie:
			classType = MovieView.self
		case is Series:
			classType = SeriesView.self
		case is Person:
			classType = PersonView.self
		default:
			return
		}
		
		detailsView?.removeFromSuperview()
		detailsView = NSBundle.mainBundle().loadNibNamed(classType.nibName, owner: self, options: nil)[0] as! DetailsView
		
		// setup frame
		var frame = view.frame
		frame.size.height -= topLayoutGuide.length + bottomLayoutGuide.length + navBar.frame.height
		frame.origin.y += topLayoutGuide.length + navBar.frame.height
		detailsView.frame = frame
		
		view.addSubview(detailsView)
		
		detailsView.setupWithEntity(entity)
		
		navBarTitle.title = detailsView.getTitle()
		
		// set tab bar button images
		barItem.image = getNormalBarItemImageFromImage(image)
		let tintColor = (parentViewController as! UITabBarController).tabBar.tintColor.colorWithAlphaComponent(0.2)
		barItem.selectedImage = getNormalBarItemImageFromImage(image, withTintColor: tintColor)
	}
	
	@IBAction func backPressed(sender: UIBarButtonItem) {
		(parentViewController as! TabBarController).goBack()
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

