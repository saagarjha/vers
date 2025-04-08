//
//  main.swift
//  vers
//
//  Created by Saagar Jha on 8/30/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import Foundation

// A generic application that doesn't have a special about window
func _generic(_ appName: String) -> String {
	guard let infoDictionary = NSDictionary(contentsOfFile: "/System/Applications/\(appName).app/Contents/Info.plist") as? [CFString: Any],
		let shortVersion = infoDictionary["CFBundleShortVersionString" as CFString] as? String,
		let version = infoDictionary[kCFBundleVersionKey] as? String else {
			return ""
	}
	return "Version \(shortVersion) (\(version))"
}

func Mac() -> String {
	return ASI_GetLocalizedMarketingName() as String
}

let macOSVersions = [
	"10.15": "macOS Catalina",
	"10.14": "macOS Mojave",
	"10.13": "macOS High Sierra",
	"10.12": "macOS Sierra",
	"10.11": "OS X El Capitan",
	"10.10": "OS X Yosemite",
	"10.9": "OS X Mavericks",
	"10.8": "OS X Mountain Lion",
	"10.7": "Mac OS X Lion",
	"10.6": "Mac OS X Snow Leopard",
	"10.5": "Mac OS X Leopard",
	"10.4": "Mac OS X Tiger",
	"10.3": "Mac OS X Panther",
	"10.2": "Mac OS X Jaguar",
	"10.1": "Mac OS X Puma",
	"10.0": "Mac OS X Cheetah",
]

// Take the version we care about–the first two numbers (i.e. 10.x)
func majorVersion(ofVersion version: String) -> String {
	return version.split(separator: ".")[0..<2].joined(separator: ".")
}

func names(forVersion version: String) -> (String, String)? {
	if let name = macOSVersions[majorVersion(ofVersion: version)] {
		return (name, version)
	} else {
		guard let name = SystemDesktopAppearance?.OSName,
			  let version = SystemDesktopAppearance?.OSVersion else {
			return nil
		}
		return (name, version)
	}
}

func macOS() -> String {
	let versionDictionary = _CFCopySystemVersionDictionary() as NSDictionary
	guard let (name, version) = (versionDictionary["ProductVersion"] as? String).flatMap(names(forVersion:)),
		  let build = versionDictionary["ProductBuildVersion"] else {
		return ""
	}

	let isBeta = SDBuildInfo.currentBuildIsSeed()
	return "\(name) \(version) \(isBeta ? "Beta " : "")(\(build))"
}

func Xcode() -> String {
	let toolsInfo = DVTToolsInfo.toolsInfo()
	let version = toolsInfo.toolsVersion.name()
	let build = toolsInfo.toolsBuildVersion.name()
	let beta: String
	if let betaString = type(of: toolsInfo.toolsVersion).currentVersionBetaString {
		beta = betaString == "0" || betaString == "1" ? "beta" : "beta \(betaString) "
	} else {
		beta = ""
	}
	return "Xcode Version \(version) \(beta)(\(build))"
}

guard let flag = CommandLine.arguments.dropFirst().first else {
	exit(EXIT_FAILURE)
}

// Breaks every convention in the book. I'm doing it anyways.
switch flag {
case "Calendar":
	print(_generic("Calendar"))
case "Mac":
	print(Mac())
case "macOS":
	print(macOS())
case "Mail":
	print(_generic("Mail"))
case "Messages":
	print(_generic("Messages"))
case "Preview":
	print(_generic("Preview"))
case "Xcode":
	print(Xcode())
default:
	print()
}
