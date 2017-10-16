//
//  Headers.swift
//  vers
//
//  Created by Saagar Jha on 10/15/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import Foundation

let _CFCopySystemVersionDictionary: (@convention(c) () -> CFDictionary)! = {
	let handle = dlopen("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", RTLD_NOW)
	let function = dlsym(handle, "_CFCopySystemVersionDictionary")
	let signature = (@convention(c) () -> CFDictionary)!.self
	return unsafeBitCast(function, to: signature)
}()

let ASI_CopyFormattedSerialNumber: (@convention(c) () -> CFString)! = {
	let handle = dlopen("/System/Library/PrivateFrameworks/AppleSystemInfo.framework/AppleSystemInfo", RTLD_NOW)
	let function = dlsym(handle, "ASI_CopyFormattedSerialNumber")
	let signature = (@convention(c) () -> CFString)!.self
	return unsafeBitCast(function, to: signature)
}()

@objc protocol SDBuildInfoProtocol {
	static func currentBuildIsSeed() -> Bool
}

let SDBuildInfo: SDBuildInfoProtocol.Type! = {
	dlopen("/System/Library/PrivateFrameworks/Seeding.framework/Seeding", RTLD_NOW)
	return unsafeBitCast(NSClassFromString("SDBuildInfo"), to: SDBuildInfoProtocol.Type!.self)
}()

@objc protocol DVTToolsVersion {
	func name() -> String
}

@objc protocol DVTBuildVersion {
	func name() -> String
}

@objc protocol DVTToolsInfoProtocol {
	var toolsBetaVersion: Int { get }
	var isBeta: Bool { get }
	var toolsBuildVersion: DVTBuildVersion { get }
	var toolsVersion: DVTToolsVersion { get }
	static func toolsInfo() -> DVTToolsInfoProtocol
}

let DVTToolsInfo: DVTToolsInfoProtocol.Type! = {
	// Find the current path that xcode-select uses; this is whatever
	// /var/db/xcode_select_link is symlinked to
	let capacity = 1000
	let directory = UnsafeMutablePointer<CChar>.allocate(capacity: capacity)
	defer {
		directory.deallocate(capacity: capacity)
	}
	let size = readlink("/var/db/xcode_select_link", directory, capacity)
	directory.advanced(by: size).pointee = 0

	// Navigate the Xcode bundle to find DVTFoundation
	let url = URL(fileURLWithPath: String(cString: directory)).deletingLastPathComponent().appendingPathComponent("SharedFrameworks").appendingPathComponent("DVTFoundation.framework").appendingPathComponent("DVTFoundation")

	// Redirect stderr since the Objective-C runtime will complain about
	// duplicate symbols in dlopen
	let file = open("/dev/null", O_WRONLY)
	let originalStderr = dup(fileno(stderr))
	dup2(file, fileno(stderr))
	close(file)
	defer {
		dup2(originalStderr, fileno(stderr))
	}

	dlopen(url.path, RTLD_NOW)
	return unsafeBitCast(NSClassFromString("DVTToolsInfo"), to: DVTToolsInfoProtocol.Type!.self)
}()
