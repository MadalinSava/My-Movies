//
//  FileManager.swift
//  My Movies
//
//  Created by Madalin Sava on 05/12/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

class FileManager {
	static let instance = FileManager()
	
	private init() {
		NSLog("init file manager")
	}
}
