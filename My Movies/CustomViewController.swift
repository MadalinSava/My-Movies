//
//  CustomViewController.swift
//  My Movies
//
//  Created by Madalin Sava on 26/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class CustomViewController: UIViewController {
	
	var didAppear = false;
	
	func didAutorotate() {}
	
	// MARK: overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "didAutorotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		didAppear = true
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		didAppear = false
	}
}
