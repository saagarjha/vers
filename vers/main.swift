//
//  main.swift
//  vers
//
//  Created by Saagar Jha on 8/30/17.
//  Copyright © 2017 Saagar Jha. All rights reserved.
//

import Foundation

func Mac() -> String {
	var serial = ASI_CopyFormattedSerialNumber().takeUnretainedValue() as String
	serial = String(serial.suffix(4))
	guard let url = URL(string: "http://support-sp.apple.com/sp/product?cc=\(serial)&lang=en_US") else {
		return ""
	}
	let semaphore = DispatchSemaphore(value: 0)
	var model = ""
	URLSession.shared.dataTask(with: url) { data, response, error in
		// H̸̡̪̯ͨ͊̽̅̾̎Ȩ̬̩̾͛ͪ̈́̀́͘ ̶̧̨̱̹̭̯ͧ̾ͬC̷̙̲̝͖ͭ̏ͥͮ͟Oͮ͏̮̪̝͍M̲̖͊̒ͪͩͬ̚̚͜Ȇ̴̟̟͙̞ͩ͌͝S̨̥̫͎̭ͯ̿̔̀ͅ
		guard let data = data,
			let string = String(data: data, encoding: .utf8),
			let range1 = string.range(of: "<configCode>"),
			let range2 = string.range(of: "</configCode>") else {
				return
		}

		model = String(string[range1.upperBound..<range2.lowerBound])
		semaphore.signal()
	}.resume()
	semaphore.wait()
	return model
}

let macOSVersions = [
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

func macOS() -> String {
	let versionDictionary = _CFCopySystemVersionDictionary().takeUnretainedValue() as NSDictionary
	guard let version = versionDictionary["ProductVersion"] as? String,
		let build = versionDictionary["ProductBuildVersion"] as? String,
		let name = macOSVersions[majorVersion(ofVersion: version)] else {
			return ""
	}
	let isBeta = SDBuildInfo.currentBuildIsSeed()
	return "\(name) \(version) \(isBeta ? "Beta " : "")(\(build))"
}

func Xcode() -> String {
	let toolsInfo = DVTToolsInfo()
	let version = toolsInfo.toolsVersion.name()
	let build = toolsInfo.toolsBuildVersion.name()
	return "Xcode Version \(version) \(toolsInfo.isBeta ? "beta\(toolsInfo.toolsBetaVersion != 0 ? " \(toolsInfo.toolsBetaVersion)" : "") " : "")(\(build))"
}

guard let flag = CommandLine.arguments.dropFirst().first else {
	exit(EXIT_FAILURE)
}

// Breaks every convention in the book. I'm doing it anyways.
switch flag {
case "Mac":
	print(Mac())
case "macOS":
	print(macOS())
case "Xcode":
	print(Xcode())
default:
	print()
}
