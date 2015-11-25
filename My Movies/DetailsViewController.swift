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
	
	/*required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}*/
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		
		/*let button = UIButton(frame: CGRect(x: 0, y: 0, width: 130, height: 30))
		button.setImage(UIImage(named: "Home"), forState: UIControlState.Normal)
		button.setTitle("BEAC!!!", forState: UIControlState.Normal)
		button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
		button.addTarget(self, action: "asd", forControlEvents: UIControlEvents.TouchDown)
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
		
		let navBar = navigationController!.navigationBar
		//navBar.layoutIfNeeded()
		
		let buttonView = navigationItem.leftBarButtonItem!.customView
		let searchBar = (navigationController as! NavigationController).searchBar
		let constraint = NSLayoutConstraint(item: searchBar, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: button, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 5.0)
		searchBar.superview!.addConstraint(constraint)*/
		
		/*
		print(navigationItem.leftBarButtonItem)
		print(navigationItem.leftBarButtonItem?.customView)
		let navBar = navigationController!.navigationBar
		print(navBar.topItem)
		print(navBar.topItem?.leftBarButtonItem) // THIS
		print(navBar.topItem?.titleView)
		print(navBar.topItem?.rightBarButtonItem)
		print(navBar.backItem)
		print(navBar.backIndicatorImage)
		*/
		//navigationItem.backBarButtonItem = UIBarButtonItem(title: "Beac", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
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

