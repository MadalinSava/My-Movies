//
//  ImageSetter.swift
//  My Movies
//
//  Created by Madalin Sava on 21/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation
import UIKit

enum ImageType {
	case Poster
	case Still
	case Logo
	case Profile
	case Backdrop
}

typealias ImageSetSuccess = () -> Void

class ImageSetter {
	
	static let instance = ImageSetter()
	
	private var basePath: String! = nil
	private let queue = NSOperationQueue()
	private var configurationComplete = false
	
	private typealias ImageSize = (width: Int, name: String)
	
	private var sizes = [ImageType: [ImageSize]]()
	//private var widths = [(width: Int, type: ImageType): String]()
	private var imagesToSet = [(String?, ImageType, CGFloat, UIImageView, String?, ImageSetSuccess?)]()
	
	func setImage(path: String?, ofType type: ImageType, andWidth width: CGFloat, forView: UIImageView, defaultImage: String? = nil, success: ImageSetSuccess? = nil) {
		guard configurationComplete else {
			print("configuration not ready")
			imagesToSet.append((path, type, width, forView, defaultImage, success))
			return
		}
		
		guard let path = path else {
			if defaultImage != nil {
				forView.image = UIImage(named: defaultImage!)
			}
			return
		}
		
		let pixels = Int(ceil(pointsToPixels(width)))
		let sizeComponent = getSizeComponentForWidth(pixels, ofImageType: type)
		//print("setting image " + sizeComponent)
		
		let imageId = sizeComponent + "-" + path[1, 0]
		let tmpDirURL = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)
		let fileURL = tmpDirURL.URLByAppendingPathComponent(imageId)
		
		var image: UIImage?
		let setImage = {
			dispatch_async(dispatch_get_main_queue()) {
				if image != nil {
					forView.image = image
					//print("success")
					success?()
				} else if defaultImage != nil { // TODO: test this
					forView.image = UIImage(named: defaultImage!)
					success?()
				}
			}
		}
		
		//let onlinePath = self.basePath + sizeComponent + path
		//FileManager.instance.downloadFile(onlinePath, toFile: fileURL.path!)
		
		// TODO: move this functionality: downloadFile(url, toLocal, dataCallback, fileCallback)
		
		if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
			//dispatch_async(queue)
			queue.addOperationWithBlock() {
				image = UIImage(contentsOfFile: fileURL.path!)
				setImage()
			}
		} else {
			let onlinePath = self.basePath + sizeComponent + path
			RequestManager.instance.doBackgroundRequest(onlinePath, successBlock: { (data) -> Void in
				NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: data, attributes: nil)
				image = UIImage(data: data)
				setImage()
			})
		}
	}
	
	private init() {
		
		queue.qualityOfService = NSQualityOfService.UserInitiated
		queue.maxConcurrentOperationCount = 1
		
		NSLog("image setter init")
		print(NSOperationQueueDefaultMaxConcurrentOperationCount)
		// TESTING - delete cache
		if true {
			let manager = NSFileManager.defaultManager()
			let tempDir = NSTemporaryDirectory()
			let contents = try! manager.contentsOfDirectoryAtPath(tempDir)
			for item in contents {
				try! manager.removeItemAtPath(tempDir + item)
			}
		}
		
		Api.instance.getConfiguration(gotConfiguration)
	}
	
	private func gotConfiguration(config: JSON) {
		guard configurationComplete == false else {
			print("configuration already ready")
			return
		}
		
		let images = config["images"]
		basePath = images["secure_base_url"].stringValue
		
		sizes[.Poster] = getSizesFromJSON(images["poster_sizes"])
		sizes[.Still] = getSizesFromJSON(images["still_sizes"])
		sizes[.Logo] = getSizesFromJSON(images["logo_sizes"])
		sizes[.Profile] = getSizesFromJSON(images["profile_sizes"])
		sizes[.Backdrop] = getSizesFromJSON(images["backdrop_sizes"])
		
		configurationComplete = true
		
		for params in imagesToSet {
			setImage(params.0, ofType: params.1, andWidth: params.2, forView: params.3, defaultImage: params.4, success: params.5)
		}
	}
	
	private func getSizesFromJSON(json: JSON) -> [ImageSize] {
		var list = [ImageSize]()
		
		for size in json.arrayValue {
			let sizeStr = size.stringValue
			var width: Int
			if sizeStr.characters.first == "w" {
				width = Int(sizeStr[1, 0])!
			} else if sizeStr == "original" {
				width = 1000
			} else {
				continue
			}
			list.append((width, sizeStr))
		}
		
		return list
	}
	
	private func getSizeComponentForWidth(width: Int, ofImageType type: ImageType) -> String {
		let minSize = sizes[type]!.reduce(nil) { (minSize: ImageSize?, size: ImageSize) -> ImageSize? in
			guard let minSize = minSize else {
				return size
			}
			if minSize.width < width {
				if minSize.width > size.width {
					return minSize
				}
				return size
			}
			if size.width >= width && size.width < minSize.width {
				return size
			}
			return minSize
		}!
		return minSize.name
	}
}
