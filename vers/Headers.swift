//
//  Headers.swift
//  vers
//
//  Created by Saagar Jha on 10/15/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import Foundation

let _CFCopySystemVersionDictionary: (@convention(c) () -> CFDictionary)! = {
	let handle = dlopen("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", RTLD_LAZY)
	let function = dlsym(handle, "_CFCopySystemVersionDictionary")
	let signature = (@convention(c) () -> CFDictionary)?.self
	return unsafeBitCast(function, to: signature)
}()

let ASI_GetLocalizedMarketingName: (@convention(c) () -> CFString)! = {
	let handle = dlopen("/System/Library/PrivateFrameworks/AppleSystemInfo.framework/AppleSystemInfo", RTLD_LAZY)
	let function = dlsym(handle, "ASI_GetLocalizedMarketingName")
	let signature = (@convention(c) () -> CFString)?.self
	return unsafeBitCast(function, to: signature)
}()

@objc protocol SDBuildInfoProtocol {
	static func currentBuildIsSeed() -> Bool
}

let SDBuildInfo: SDBuildInfoProtocol.Type! = {
	dlopen("/System/Library/PrivateFrameworks/Seeding.framework/Seeding", RTLD_LAZY)
	return unsafeBitCast(NSClassFromString("SDBuildInfo"), to: SDBuildInfoProtocol.Type?.self)
}()

@objc protocol DVTToolsVersion {
	func name() -> String
	static func setCurrentBetaVersionFromPlistFile(_: URL)
	static var currentVersionBetaString: String? { get }
}

@objc protocol DVTBuildVersion {
	func name() -> String
}

@objc protocol DVTToolsInfoProtocol {
	var toolsBetaVersion: Int { get }
	var toolsBuildVersion: DVTBuildVersion { get }
	var toolsVersion: DVTToolsVersion { get }
	static func toolsInfo() -> DVTToolsInfoProtocol
}

let DVTToolsInfo: DVTToolsInfoProtocol.Type! = {
	// Use the xcode_select_link symlink…
	let XcodeContents = URL(fileURLWithPath: "/var/select/developer_dir")
		// …to find the Xcode developer directory. Then,
		.resolvingSymlinksInPath()
		// delete the "Developer" part.
		.deletingLastPathComponent()

	let url =
		XcodeContents
		.appendingPathComponent("SharedFrameworks")
		.appendingPathComponent("DVTFoundation.framework")
		.appendingPathComponent("DVTFoundation")

	// Redirect stderr since the Objective-C runtime will complain about
	// duplicate symbols in dlopen
	let devNull = open("/dev/null", O_WRONLY)
	let originalStderr = dup(fileno(stderr))
	dup2(devNull, fileno(stderr))
	close(devNull)
	defer {
		dup2(originalStderr, fileno(stderr))
	}

	dlopen(url.path, RTLD_LAZY)
	unsafeBitCast(NSClassFromString("DVTToolsVersion"), to: DVTToolsVersion.Type?.self)!.setCurrentBetaVersionFromPlistFile(
		XcodeContents
			.appendingPathComponent("Resources")
			.appendingPathComponent("BetaVersion.plist"))

	return unsafeBitCast(NSClassFromString("DVTToolsInfo"), to: DVTToolsInfoProtocol.Type?.self)
}()

@objc protocol SystemDesktopAppearanceProtocol {
	static var OSName: String { get }
	static var OSVersion: String { get }
}

let SystemDesktopAppearance: SystemDesktopAppearanceProtocol.Type? = {
	dlopen("/System/Library/PrivateFrameworks/SystemDesktopAppearance.framework/SystemDesktopAppearance", RTLD_LAZY)
	return unsafeBitCast(NSClassFromString("SystemDesktopAppearance"), to: SystemDesktopAppearanceProtocol.Type?.self)
}()
