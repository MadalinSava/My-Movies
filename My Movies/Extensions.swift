//
//  Extensions.swift
//  My Movies
//
//  Created by Madalin Sava on 21/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

// MARK: String

// subscripts
extension String {
	
	subscript (i: Int) -> Character {
		return self[self.startIndex.advancedBy(i)]
	}
	
	subscript (i: Int) -> String {
		return String(self[i] as Character)
	}
	
	subscript (start: Int, var end: Int) -> String {
		let firstIndex = (start >= 0 ? startIndex : endIndex)
		let secondIndex = (end > 0 ? startIndex : endIndex)
		return substringWithRange(Range(start: firstIndex.advancedBy(start), end: secondIndex.advancedBy(end)))
	}
}

extension String {
	var lenght: Int {
		return characters.count
	}
}
