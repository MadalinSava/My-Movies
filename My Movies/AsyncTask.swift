//
//  AsyncTask.swift
//  My Movies
//
//  Created by Madalin Sava on 06/12/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

protocol AsyncTask: class {
	func start()
	
	// call delegate?.didCancel() in the implementation if needed?
	func cancel()
}

protocol AsyncResumableTask: AsyncTask {
	func pause()
	
	func resume()
}

protocol AsyncTaskDelegate: class {
	func didCancel()
}
