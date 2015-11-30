//
//  NavigationBar.swift
//  My Movies
//
//  Created by Madalin Sava on 24/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

public class GalleryView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	public var shouldStartSlideshow = false {
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
	
	required public init?(coder aDecoder: NSCoder) {
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
	
	func resetLayout() {
		// keep the page
		let prevWidth = layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!.frame.width
		let page = round(contentOffset.x / prevWidth)
		contentOffset.x = frame.width * page
		
		collectionViewLayout.invalidateLayout()
	}
	
	// MARK: data source
	public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}
	
	public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return frame.size
	}
	
	public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 0.0
	}
	
	public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = dequeueReusableCellWithReuseIdentifier(GalleryCell.reuseIdentifier, forIndexPath: indexPath) as! GalleryCell
		cell.setImage(images[indexPath.row], ofType: imageType) { [unowned self] in
			if indexPath.row == 0 && self.firstImageSet == false {
				self.firstImageSet = true
			}
		}
		return cell
	}
	
	public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		slideshowTimer?.invalidate()
	}
	
	public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		tryStartSlideshow()
	}
	
	// MARK: private stuff
	private func tryStartSlideshow() {
		if firstImageSet && shouldStartSlideshow {
			slideshowTimer = NSTimer(timeInterval: slideshowInterval, target: self, selector: "nextImage", userInfo: nil, repeats: true)
			NSRunLoop.currentRunLoop().addTimer(slideshowTimer!, forMode: NSRunLoopCommonModes)
		}
	}
	
	private func getCurrentItem() -> Int {
		return Int(round(contentOffset.x / frame.width))
	}
	
	func nextImage() {
		scrollToItemAtIndexPath(NSIndexPath(forItem: (getCurrentItem() + 1) % images.count, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
	}
}
