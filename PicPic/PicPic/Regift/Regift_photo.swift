//
//  Regift.swift
//  Regift
//
//  Created by Matthew Palmer on 27/12/2014.
//  Copyright (c) 2014 Matthew Palmer. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices
import AVFoundation

public typealias TimePointPhoto = CMTime

/// Errors thrown by Regift
public enum RegiftError_photo: String, ErrorType {
    case DestinationNotFound = "The temp file destination could not be created or found"
    case AddFrameToDestination = "An error occurred when adding a frame to the destination"
    case DestinationFinalize = "An error occurred when finalizing the destination"
}

/// Easily convert a video to a GIF.
///
/// Usage:
///
///      let regift = Regift(sourceFileURL: movieFileURL, frameCount: 24, delayTime: 0.5, loopCount: 7)
///      print(regift.gifURL)
///
public struct Regift_photo {
    private struct Constants {
        static let FileName = "regift.gif"
        static let TimeInterval: Int32 = 600
        static let Tolerance = 0.01
    }
    
    private let sourceArray: Array<UIImage>
    private let movieLength: Double
    private let delayTime: Float
    private let loopCount: Int
    private let frameCount: Int
    
    /// Create a GIF from a movie stored at the given URL.
    ///
    /// :param: frameCount The number of frames to include in the gif; each frame has the same duration and is spaced evenly over the video.
    /// :param: delayTime The amount of time each frame exists for in the GIF.
    /// :param: loopCount The number of times the GIF will repeat. This defaults to 0, which means that the GIF will repeat infinitely.
    public init(sourceArray: Array<UIImage>, delayTime: Float, loopCount: Int = 0) {
        self.sourceArray = sourceArray
        self.delayTime = delayTime
        self.loopCount = loopCount
        self.movieLength = Double(sourceArray.count) * Double(delayTime)
        self.frameCount = sourceArray.count
    }
    
    /// Get the URL of the GIF created with the attributes provided in the initializer.
    public func createGif() -> NSURL? {
        let fileProperties = [kCGImagePropertyGIFDictionary as String:
            [
                kCGImagePropertyGIFLoopCount as String: loopCount
            ]]
        
        let frameProperties = [kCGImagePropertyGIFDictionary as String:
            [
                kCGImagePropertyGIFDelayTime as String: delayTime
            ]]
        // The total length of the movie, in seconds.
        //let movieLength = Float(asset.duration.value) / Float(asset.duration.timescale)
        
        // How far along the video track we want to move, in seconds.
        let increment = Float(movieLength) / Float(frameCount)
        
        // Add each of the frames to the buffer
        var timePoints: [TimePointPhoto] = []
        
        for frameNumber in 0 ..< frameCount {
            let seconds: Float64 = Float64(increment) * Float64(frameNumber)
            let time = CMTimeMakeWithSeconds(seconds, Constants.TimeInterval)
            print(time)
            print("in for ",seconds)
            timePoints.append(time)
        }
        
        do {
            return try createGIFForTimePoints(timePoints, fileProperties: fileProperties, frameProperties: frameProperties, frameCount: frameCount)
        } catch {
            return nil
        }
    }
    
    /// Create a GIF using the given time points in a movie file stored at the URL provided.
    ///
    /// :param: timePoints An array of `TimePoint`s (which are typealiased `CMTime`s) to use as the frames in the GIF.
    /// :param: URL The URL of the video file to convert
    /// :param: fileProperties The desired attributes of the resulting GIF.
    /// :param: frameProperties The desired attributes of each frame in the resulting GIF.
    public func createGIFForTimePoints(timePoints: [TimePointPhoto], fileProperties: [String: AnyObject], frameProperties: [String: AnyObject], frameCount: Int) throws -> NSURL {
        let temporaryFile = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(Constants.FileName)
        let fileURL = NSURL(fileURLWithPath: temporaryFile)
        
        guard let destination = CGImageDestinationCreateWithURL(fileURL, kUTTypeGIF, frameCount, nil) else {
            throw RegiftError_photo.DestinationNotFound
        }
        
//        CGImageDestinationSetProperties(destination, fileProperties as CFDictionaryRef)
        var i: Int = 0
        for _ in timePoints {
            let imageData = UIImageJPEGRepresentation(sourceArray[i] as UIImage, 1)!
            let dataProvider = CGDataProviderCreateWithCFData(imageData)
            let imageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
            print(frameProperties)
            CGImageDestinationAddImage(destination, imageRef!, frameProperties as CFDictionaryRef)
            i++
        }
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionaryRef)
        
        // Finalize the gif
        if !CGImageDestinationFinalize(destination) {
            throw RegiftError_photo.DestinationFinalize
        }
        
        return fileURL
    }
}
