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

class ImageSetter {
	
	static let instance = ImageSetter()
	
	private var basePath: String! = nil
	private let queue = NSOperationQueue()
	private var configurationComplete = false
	
	private typealias ImageSize = (width: Int, name: String)
	
	private var sizes = [ImageType: [ImageSize]]()
	//private var widths = [(width: Int, type: ImageType): String]()
	
	private let worker: QueuedAsyncWorker
	
	func setImageAsync(path: String?, ofType type: ImageType, andWidth width: CGFloat, forView: UIImageView, defaultImage: String? = nil, success: SimpleBlock? = nil) -> AsyncTask? {
		
		guard let path = path else {
			if defaultImage != nil {
				forView.image = UIImage(named: defaultImage!)
			}
			return nil
		}
		
		let taskChain = TaskChain(operationQueue: queue)
		taskChain.completionBlock = { [weak taskChain, unowned self] didSucceed in
			//NSLog("chain completed with " + (didSucceed ? "SUCCESS" : "FAILURE"))
			self.worker.remove(taskChain!)
		}
		
		let setImageTask = AsyncChainTask()
		let setImageBlock = { [weak setImageTask] (newImage: UIImage?) in {
				NSOperationQueue.mainQueue().addOperationWithBlock {
					if forView.image != nil {
						//print("oh noes")
					}
					if newImage != nil {
						forView.image = newImage
						//print("success")
						success?()
					} else if defaultImage != nil { // TODO: test this
						forView.image = UIImage(named: defaultImage!)
						success?()
					}
					setImageTask?.done()
				}
			}
		}
		
		let mainTask = SyncChainTask()
		mainTask.start = { [weak mainTask, unowned self] in
			
			let pixels = Int(ceil(pointsToPixels(width)))
			let sizeComponent = self.getSizeComponentForWidth(pixels, ofImageType: type)
			//print("setting image " + sizeComponent)
			
			let imageId = sizeComponent + "-" + path[1, 0]
			let tmpDirURL = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)
			let fileURL = tmpDirURL.URLByAppendingPathComponent(imageId)
			
			var getDataTask: ChainTask
			if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
				getDataTask = SyncChainTask()
				getDataTask.start = { [weak getDataTask] in
					let newImage = UIImage(contentsOfFile: fileURL.path!)
					setImageTask.start = setImageBlock(newImage)
					getDataTask?.next = setImageTask
					getDataTask?.done()
				}
			} else {
				let onlinePath = self.basePath + sizeComponent + path
				getDataTask = AsyncChainTask()
				getDataTask.start = { [weak getDataTask] in
					let getDataTaskAsync = getDataTask as? AsyncChainTask
					getDataTaskAsync?.task = RequestManager.instance.doBackgroundRequest(onlinePath, successBlock: { [weak getDataTaskAsync] data  in
						
						NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: data, attributes: nil)
						let newImage = UIImage(data: data)
						setImageTask.start = setImageBlock(newImage)
						getDataTaskAsync?.next = setImageTask
						
						getDataTaskAsync?.done()
					}, errorBlock: { [weak getDataTaskAsync] _ in
						getDataTaskAsync?.done()
					})
				}
			}
			
			mainTask?.next = getDataTask
			
			mainTask?.done()
		}
		
		taskChain.currentTask = mainTask
		worker.addTask(taskChain)
		
		return taskChain
	}
	
	func setImage(path: String?, ofType type: ImageType, andWidth width: CGFloat, forView: UIImageView, defaultImage: String? = nil, success: SimpleBlock? = nil) -> AsyncTask? {
		guard configurationComplete else {
			print("configuration not ready")
			return nil
		}
		
		guard let path = path else {
			if defaultImage != nil {
				forView.image = UIImage(named: defaultImage!)
			}
			return nil
		}
		
		let pixels = Int(ceil(pointsToPixels(width)))
		let sizeComponent = getSizeComponentForWidth(pixels, ofImageType: type)
		//print("setting image " + sizeComponent)
		
		let imageId = sizeComponent + "-" + path[1, 0]
		let tmpDirURL = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)
		let fileURL = tmpDirURL.URLByAppendingPathComponent(imageId)
		
		let setImage = { (image: UIImage?) in
			dispatch_async(dispatch_get_main_queue()) {
				if forView.image != nil {
					print("wat")
				}
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
				setImage(UIImage(contentsOfFile: fileURL.path!))
			}
		} else {
			let onlinePath = self.basePath + sizeComponent + path
			return RequestManager.instance.doBackgroundRequest(onlinePath, successBlock: { [unowned self] (data) -> Void in
				
				self.queue.addOperationWithBlock() {
					NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: data, attributes: nil)
					setImage(UIImage(data: data))
				}
			})
		}
		return nil
	}
	
	private init() {
		
		queue.qualityOfService = .UserInitiated
		
		//NSLog("image setter init")
		print(NSOperationQueueDefaultMaxConcurrentOperationCount)
		//#if DEBUG
		// TESTING - delete cache
		if false {
			let manager = NSFileManager.defaultManager()
			let tempDir = NSTemporaryDirectory()
			let contents = try! manager.contentsOfDirectoryAtPath(tempDir)
			for item in contents {
				try! manager.removeItemAtPath(tempDir + item)
			}
		}
		//#endif
		
		worker = QueuedAsyncWorker(operationQueue: queue, maxOngoingTasks: 0)
		
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
		worker.maxOngoingTasks = 5
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
