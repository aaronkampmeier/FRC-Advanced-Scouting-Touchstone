//
//  TeamimageLoader.swift
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/3/19.
//  Copyright © 2019 Kampfire Technologies. All rights reserved.
//

import Foundation
import Crashlytics
import AWSS3
import AWSMobileClient

class TeamImageLoader {
    static var `default`: TeamImageLoader = TeamImageLoader()
    
    init() {
    }
    
    let imageCacheURL = FileManager.default.temporaryDirectory.appendingPathComponent("FAST Image Cache", isDirectory: true)
	let loadingQueue = DispatchQueue.global(qos: .utility)
    
    func clearCache() {
        do {
            try FileManager.default.removeItem(at: imageCacheURL)
        } catch {
            CLSNSLogv("Error deleting image cache: \(error)", getVaList([]))
			if (error as NSError).code != 4 {
				//Code 4 is the dir doesn't exist, don't treat as error
				Crashlytics.sharedInstance().recordError(error)
			}
        }
    }
    
	func loadImage(withAttributes attributes: ScoutedTeam.Image, noCache: Bool = false, progressBlock: @escaping (Progress) -> Void, completionHandler: @escaping (UIImage?, Error?) -> Void) {
		//Check if it is stored in the cache
		loadingQueue.async {
			let cachePath = self.imageCacheURL.appendingPathComponent("\(attributes.bucket)/\(attributes.key)")
			if FileManager.default.fileExists(atPath: cachePath.path) && !noCache {
				if let image = UIImage(contentsOfFile: cachePath.path) {
					completionHandler(image, nil)
					
					//Check the last time it was reloaded and if it is over a certain amount of time than reload it
					do {
						let fileAttributes = try FileManager.default.attributesOfItem(atPath: cachePath.path) as NSDictionary
						if let modDate = fileAttributes.fileModificationDate() {
							if abs(modDate.timeIntervalSinceNow) > 60 * 60 {
								self.loadImage(withAttributes: attributes, noCache: true, progressBlock: progressBlock, completionHandler: completionHandler)
							}
						}
					} catch {
						CLSNSLogv("Error getting the attributes of team image (key: \(attributes.key): \(error)", getVaList([]))
						Crashlytics.sharedInstance().recordError(error)
					}
				} else {
					//Load from S3
					self.loadImage(withAttributes: attributes, noCache: true, progressBlock: progressBlock, completionHandler: completionHandler)
				}
			} else {
				//Load from S3
				let expression = AWSS3TransferUtilityDownloadExpression()
				expression.progressBlock = {(task, progress) in
					progressBlock(progress)
				}
				
				AWSS3TransferUtility.default().downloadData(fromBucket: attributes.bucket, key: attributes.key, expression: expression, completionHandler: { (task, url, data, error) in
					if let error = error {
						if (error as NSError).code == -1200 {
							CLSNSLogv("Error downloading team image (key: \(attributes.key): Secure connection to the server could not be made", getVaList([]))
						} else {
							CLSNSLogv("Error downloading team image (key: \(attributes.key): \(error)", getVaList([]))
						}
						
						if #available(iOS 12.0, *) {
							if FASTNetworkManager.main.isOnline() {
								Crashlytics.sharedInstance().recordError(error)
							} else {
								FASTNetworkManager.main.registerUpdateOnReconnect {[weak self] in
									self?.loadImage(withAttributes: attributes, noCache: true, progressBlock: progressBlock, completionHandler: completionHandler)
								}
							}
						} else {
							Crashlytics.sharedInstance().recordError(error)
						}
						
						completionHandler(nil, error)
					} else {
						//                    DispatchQueue.main.async {
						if let data = data {
							if let image = UIImage(data: data) {
								completionHandler(image, nil)
								
								//Cache it
								do {
									//Save the data to a file
									try FileManager.default.createDirectory(at: cachePath.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
									FileManager.default.createFile(atPath: cachePath.path, contents: data, attributes: nil)
								} catch {
									CLSNSLogv("Error saving image to cache: \(error)", getVaList([]))
									Crashlytics.sharedInstance().recordError(error)
								}
							} else {
								completionHandler(nil, ImageError.CorruptData)
								Crashlytics.sharedInstance().recordError(ImageError.CorruptData)
							}
						} else {
							completionHandler(nil, ImageError.NoData)
							Crashlytics.sharedInstance().recordError(ImageError.NoData)
						}
						//                    }
					}
				}).continueWith(block: { (task) -> Any? in
					if let error = task.error {
						CLSNSLogv("Error executing team image download: \(error)", getVaList([]))
						completionHandler(nil, error)
						
						if #available(iOS 12.0, *) {
							if FASTNetworkManager.main.isOnline() {
								Crashlytics.sharedInstance().recordError(error)
							} else {
								FASTNetworkManager.main.registerUpdateOnReconnect {
									self.loadImage(withAttributes: attributes, noCache: false, progressBlock: progressBlock, completionHandler: completionHandler)
								}
							}
						} else {
							Crashlytics.sharedInstance().recordError(error)
						}
					}
					
					return nil
				})
			}
		}
	}
    
    enum ImageError: Error {
        case CorruptData
        case NoData
    }
}
