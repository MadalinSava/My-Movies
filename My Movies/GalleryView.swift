//
//  NavigationBar.swift
//  My Movies
//
//  Created by Madalin Sava on 24/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

class GalleryView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	var shouldStartSlideshow = false {
		didSet {
			tryStartSlideshow()
		}
	}
	
	private var images = [String]()
	private var imageType: ImageType!
	private var firstImageSet = false {
		didSet {
			tryStartSlideshow()
		}
	}
	private var slideshowTimer: NSTimer?
	private let slideshowInterval = 5.0
	
	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		let layout = UICollectionViewFlowLayout(coder: aDecoder)!
		layout.scrollDirection = .Horizontal
		collectionViewLayout = layout
		
		delegate = self
		dataSource = self
		
		registerNib(UINib(nibName: "GalleryCell", bundle: nil), forCellWithReuseIdentifier: GalleryCell.reuseIdentifier)
		
		bounces = false
		showsHorizontalScrollIndicator = false
		
		backgroundColor = UIColor.blackColor()
		
		pagingEnabled = true
	}
	
	func setImages(images: [String], ofType imageType: ImageType) {
		self.images = images
		self.imageType = imageType
		
		reloadData()
	}
	
	func stopSlideshow() {
		slideshowTimer?.invalidate()
	}
	
	func resetLayout() {
		
		stopSlideshow()
		
		guard let prevWidth = layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.frame.width else {
			return
		}
		
		let page = ceil(contentOffset.x / prevWidth)
		
		collectionViewLayout.invalidateLayout()
		
		setNeedsLayout()
		layoutIfNeeded()
		
		contentOffset.x = frame.width * page
		
		tryStartSlideshow()
	}
	
	// MARK: data source
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return frame.size
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 0.0
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = dequeueReusableCellWithReuseIdentifier(GalleryCell.reuseIdentifier, forIndexPath: indexPath) as! GalleryCell
		//NSLog("set image for \(indexPath.row)")
		let observable = cell.setImage(images[indexPath.row], ofType: imageType)
		if indexPath.row == 0 && firstImageSet == false {
			_ = observable.subscribeCompleted {
				self.firstImageSet = true
			}
		}
		return cell
	}
	
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		stopSlideshow()
	}
	
	func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		tryStartSlideshow()
	}
	
	// MARK: private stuff
	private func tryStartSlideshow() {
		if firstImageSet && shouldStartSlideshow {
			slideshowTimer = NSTimer.scheduleEvery(slideshowInterval, target: nextImage)
		}
	}
	
	private func getCurrentItem() -> Int {
		print(contentOffset.x, frame.width, round(contentOffset.x / frame.width))
		return Int(round(contentOffset.x / frame.width))
	}
	
	func nextImage() {
		var nextItem = (getCurrentItem() + 1) % images.count
		/*if nextItem == 0 {
			//return
		} else {
			nextItem = images.count - 1
		}*/
		scrollToItemAtIndexPath(NSIndexPath(forItem: nextItem, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
	}
}
