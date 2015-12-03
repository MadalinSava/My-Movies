//
//  Utils.swift
//  My Movies
//
//  Created by Madalin Sava on 16/11/15.
//  Copyright © 2015 Madalin Sava. All rights reserved.
//

import Foundation

// MARK: operator =?
// if right is not nil, assign
infix operator =? { associativity right precedence 90 }

func =? <T> (inout left: T, right: T?) {
	if right != nil {
		left = right!
	}
}

func =? <T> (inout left: T?, right: T?) {
	if right != nil {
		left = right!
	}
}

// MARK: operator =~?
// if right is not nil and not default value, assign
infix operator =~? { associativity right precedence 90 }

// number
func =~? <T: SignedNumberType> (inout left: T?, right: T) {
	if right != 0 {
		left = right
	}
}

func =~? <T: SignedNumberType> (inout left: T?, right: T?) {
	if right != nil && right != 0 {
		left = right
	}
}

// string
func =~? (inout left: String?, right: String) {
	if right != "" {
		left = right
	}
}

func =~? (inout left: String?, right: String?) {
	if right != nil && right != "" {
		left = right
	}
}

// MARK: operator ?=
// if left is nil, assign
infix operator ?= { associativity right precedence 90 }

func ?= <T> (inout left: T?, right: T) {
	if left == nil {
		left = right
	}
}
func ?= <T> (inout left: T?, right: T?) {
	if left == nil {
		left = right
	}
}

// MARK: operator ?=~?
// if left is nil and right is not nil and not default value, assign
infix operator ?=~? { associativity right precedence 90 }

// number
func ?=~? <T: SignedNumberType> (inout left: T?, right: T) {
	if left == nil && right != 0 {
		left = right
	}
}

func ?=~? <T: SignedNumberType> (inout left: T?, right: T?) {
	if left == nil && right != nil && right != 0 {
		left = right
	}
}

// string
func ?=~? (inout left: String?, right: String) {
	if left == nil && right != "" {
		left = right
	}
}

func ?=~? (inout left: String?, right: String?) {
	if left == nil && right != nil && right != "" {
		left = right
	}
}

// MARK: operator ~??
// return left if it's not nil and it's not default value; otherwise, return right
infix operator ~?? { associativity right precedence 131 }

// number
func ~??<T: SignedNumberType>(optional: T?, @autoclosure defaultValue: () throws -> T) -> T {
	return try! (optional != nil && optional! != 0) ? optional! : defaultValue()
}

func ~??<T: SignedNumberType>(value: T, @autoclosure defaultValue: () throws -> T) -> T {
	return try! value != 0 ? value : defaultValue()
}

func ~??<T: SignedNumberType>(optional: T?, @autoclosure defaultValue: () throws -> T?) -> T {
	return try! (optional != nil && optional! != 0) ? optional! : defaultValue()!
}

func ~??<T: SignedNumberType>(value: T, @autoclosure defaultValue: () throws -> T?) -> T {
	return try! value != 0 ? value : defaultValue()!
}

// string
func ~??(optional: String?, @autoclosure defaultValue: () throws -> String) -> String {
	return try! (optional != nil && optional! != "") ? optional! : defaultValue()
}

func ~?? (value: String, @autoclosure defaultValue: () throws -> String) -> String {
	return try! value != "" ? value : defaultValue()
}

func ~??(optional: String?, @autoclosure defaultValue: () throws -> String?) -> String {
	return try! (optional != nil && optional! != "") ? optional! : defaultValue()!
}

func ~?? (value: String, @autoclosure defaultValue: () throws -> String?) -> String {
	return try! value != "" ? value : defaultValue()!
}

// MARK: operator ~?
// return left if it's not nil and it's not default value
postfix operator ~? { }

// number
postfix func ~?<T: SignedNumberType>(optional: T?) -> T? {
	return (optional != nil && optional! != 0) ? optional! : nil
}

postfix func ~?<T: SignedNumberType>(value: T) -> T? {
	return value != 0 ? value : nil
}

// string
postfix func ~? (optional: String?) -> String? {
	return (optional != nil && optional! != "") ? optional! : nil
}

postfix func ~? (value: String) -> String? {
	return value != "" ? value : nil
}

// MARK: operator +?
// add if both are not nil
infix operator +? { associativity right precedence 140 }

func +? (left: String?, right: String?) -> String? {
	if left != nil && right != nil {
		return left! + right!
	}
	return nil
}

func +? (left: String, right: String?) -> String? {
	if right != nil {
		return left + right!
	}
	return nil
}

func +? (left: String?, right: String) -> String? {
	if left != nil {
		return left! + right
	}
	return nil
}

// MARK: operator !!
// negate a boolean
prefix operator !! {}

prefix func !! (inout obj: Bool) {
	obj = !obj
}

prefix func !! (inout obj: Bool?) {
	guard obj != nil else {
		return
	}
	obj = !obj!
}
