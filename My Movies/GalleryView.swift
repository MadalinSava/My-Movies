//
//  NavigationBar.swift
//  My Movies
//
//  Created by Madalin Sava on 24/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import UIKit

@IBDesignable
class GalleryView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	private var images = [String]()
	private var imageType: ImageType!
	
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
	}
	
	func setImages(images: [String], ofType imageType: ImageType) {
		self.images = images
		self.imageType = imageType
		
		// TODO: handle zero items
		reloadData()
	}
	
	/*override func layoutSubviews() {
		super.layoutSubviews()
	}*/
	
	
	/*override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
		return super.awakeAfterUsingCoder(aDecoder)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}*/
	
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
		cell.setImage(images[indexPath.row], ofType: imageType)
		
		return cell
	}
}
