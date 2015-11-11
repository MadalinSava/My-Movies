//
//  SecondViewController.swift
//  My Movies
//
//  Created by Madalin Sava on 09/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
	
	var metadata: JSON! = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		
		tabBarItem!.enabled = true
	}
	
	override func viewDidAppear(animated: Bool) {
		
		var nibName: String
		switch metadata["media_type"] {
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
		detailsView.metadata = metadata
		view.addSubview(detailsView)
		
		//print(view.frame)
		//print(detailsView.frame)
		
		var frame = view.frame
		frame.size.height -= topLayoutGuide.length + bottomLayoutGuide.length
		frame.origin.y += topLayoutGuide.length
		detailsView.frame = frame
		//detailsView.setNeedsDisplay()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

