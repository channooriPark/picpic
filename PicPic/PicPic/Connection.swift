//
//  Connection.swift
//  PicPic
//
//  Created by 김범수 on 2016. 1. 23..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//
//  nsurlstreamtask 대용 but 느림

import Foundation

class Connection: NSObject, NSStreamDelegate {
    var host:String?
    var port:Int?
    var inputStream: NSInputStream?
    var outputStream: NSOutputStream?
    
    func connect(host: String, port: Int) {
        
        self.host = host
        self.port = port
        
        NSStream.getStreamsToHostWithName(host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        if inputStream != nil && outputStream != nil {
            
            // Set delegate
            inputStream!.delegate = self
            outputStream!.delegate = self
            
            // Schedule
            inputStream!.scheduleInRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            outputStream!.scheduleInRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            
            print("Start open()")
            
            // Open!
            inputStream!.open()
            outputStream!.open()
        }
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        if aStream === inputStream {
            switch eventCode {
            case NSStreamEvent.ErrorOccurred:
                print("input: ErrorOccurred: \(aStream.streamError?.description)")
            case NSStreamEvent.OpenCompleted:
                print("input: OpenCompleted")
            case NSStreamEvent.HasBytesAvailable:
                print("input: HasBytesAvailable")
            case NSStreamEvent.EndEncountered:
                print("input: End encountered")
                
                // Here you can `read()` from `inputStream`
                
            default:
                break
            }
        }
        else if aStream === outputStream {
            switch eventCode {
            case NSStreamEvent.ErrorOccurred:
                print("output: ErrorOccurred: \(aStream.streamError?.description)")
            case NSStreamEvent.OpenCompleted:
                print("output: OpenCompleted")
            case NSStreamEvent.HasSpaceAvailable:
                print("output: HasSpaceAvailable")
                
                // Here you can write() to `outputStream`
                
            default:
                break
            }
        }
    }
    
    func read() -> String
    {
        let startTime = NSDate.timeIntervalSinceReferenceDate()
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        var buffer = [UInt8](count: 4096, repeatedValue: 0)
        var output = ""
        
        while currentTime - startTime < 4
        {
            while (self.inputStream!.hasBytesAvailable){
                var len = self.inputStream!.read(&buffer, maxLength: buffer.count)
                if(len > 0){
                    output = NSString(bytes: &buffer, length: buffer.count, encoding: NSUTF8StringEncoding) as! String
                    
                }
            }
            if output.hasSuffix("\"msg\" : \"success\",    \"result\" : 0 }")
            {
                break
            }
            currentTime = NSDate.timeIntervalSinceReferenceDate()
        }
        

        
        return output
    }
    
    func send(bytes: [UInt8])
    {
        self.outputStream!.write(bytes, maxLength: bytes.count)
    }
    
    func disconnect()
    {
        self.inputStream!.close()
        self.outputStream!.close()
        
        self.inputStream = nil
        self.outputStream = nil
    }
}