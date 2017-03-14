//
//  ViewController.swift
//  iosSampleApp
//
//  Created by mac on 3/13/17.
//  CallerID.com
//

import UIKit
import CocoaAsyncSocket

class ViewController: UITableViewController, GCDAsyncUdpSocketDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start UDP server to listen to CallerID.com port (3520)
        startServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    fileprivate var _socket: GCDAsyncUdpSocket?
    fileprivate var socket: GCDAsyncUdpSocket? {
        get {
            if _socket == nil {
                _socket = getNewSocket()
            }
            return _socket
        }
        set {
            if _socket != nil {
                _socket?.close()
            }
            _socket = newValue
        }
    }
    
    fileprivate func getNewSocket() -> GCDAsyncUdpSocket? {
        
        // set port to CallerID.com port --> 3520
        let port = UInt16(3520)
        
        // Bind to CallerID.com port (3520)
        let sock = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            
            try sock.bind(toPort: port)
            try sock.enableBroadcast(true)
            
        } catch _ as NSError {
            
            return nil
            
        }
        return sock
    }
    
    fileprivate func startServer() {
        
        do {
            try socket?.beginReceiving()
        } catch _ as NSError {
            
            return
            
        }
        
    }
    
    fileprivate func stopServer(_ sender: AnyObject) {
        if socket != nil {
            socket?.pauseReceiving()
        }
        
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        if let udpRecieved = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            
            // parse and handle udp data----------------------------------------------
            
            // declare used variables for matching
            var lineNumber = "n/a"
            var startOrEnd = "n/a"
            var inboundOrOutbound = "n/a"
            var duration = "n/a"
            var ckSum = "B"
            var callRing = "n/a"
            var callTime = "01/01 0:00:00"
            var phoneNumber = "n/a"
            var callerId = "n/a"
            var detailedType = "n/a"
            var isDetailed = false
            
            // define CallerID.com regex strings used for parsing CallerID.com hardware formats
            let callRecordPattern = ".*(\\d\\d) ([IO]) ([ES]) (\\d{4}) ([GB]) (.)(\\d) (\\d\\d/\\d\\d \\d\\d:\\d\\d [AP]M) (.{8,15})(.*)"
            let detailedPattern = ".*(\\d\\d) ([NFR]) {13}(\\d\\d/\\d\\d \\d\\d:\\d\\d:\\d\\d)"
            
            let callRecordRegex = try! NSRegularExpression(pattern: callRecordPattern, options: [])
            let detailedRegex = try! NSRegularExpression(pattern: detailedPattern, options: [])
            
            // get matches for regular expressions
            let callRecordMatches = callRecordRegex.matches(in: udpRecieved as String, options: [], range: NSRange(location: 0, length: udpRecieved.length))
            let detailedMatches = detailedRegex.matches(in: udpRecieved as String, options: [], range: NSRange(location: 0, length: udpRecieved.length))
            
            // look at call record matches first to determine if call record
            if(callRecordMatches.count>0){
                
                // IS CALL RECORD
                // -- get groups out of regex
                callRecordRegex.enumerateMatches(in: udpRecieved as String, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length:udpRecieved.length))
                {(result : NSTextCheckingResult?, _, _) in
                    let capturedRange = result!.rangeAt(1)
                    if !NSEqualRanges(capturedRange, NSMakeRange(NSNotFound, 0)) {
                        
                        lineNumber = udpRecieved.substring(with: result!.rangeAt(1))
                        inboundOrOutbound = udpRecieved.substring(with: result!.rangeAt(2))
                        startOrEnd = udpRecieved.substring(with: result!.rangeAt(3))
                        duration = udpRecieved.substring(with: result!.rangeAt(4))
                        ckSum = udpRecieved.substring(with: result!.rangeAt(5))
                        callRing = udpRecieved.substring(with: result!.rangeAt(6)) + udpRecieved.substring(with: result!.rangeAt(7))
                        callTime = udpRecieved.substring(with: result!.rangeAt(8))
                        phoneNumber = udpRecieved.substring(with: result!.rangeAt(9))
                        callerId = udpRecieved.substring(with: result!.rangeAt(10))
                        
                    }
                }
                
                // -----------------------------
                
            }
            
            // look at detail matches if detailed record
            if(detailedMatches.count>0){
                
                // IS DETAILED RECORD
                detailedRegex.enumerateMatches(in: udpRecieved as String, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length:udpRecieved.length))
                {(result : NSTextCheckingResult?, _, _) in
                    let capturedRange = result!.rangeAt(1)
                    if !NSEqualRanges(capturedRange, NSMakeRange(NSNotFound, 0)) {
                        
                        isDetailed = true
                        
                        lineNumber = udpRecieved.substring(with: result!.rangeAt(1))
                        detailedType = udpRecieved.substring(with: result!.rangeAt(2))
                        callTime = udpRecieved.substring(with: result!.rangeAt(3))
                        
                    }
                }
                
            }
            
            //----------------------------------------------------------------------------
            //                        Display changes on screen
            //----------------------------------------------------------------------------
            // The following code is to handle window visuals
            // 
            //    This code could easily be condensed into one method handling different
            //    line numbers. We use 4 occurances of the same method hoping that clarity
            //    could be provided.
            //----------------------------------------------------------------------------
            
            // Exit this code if both regex expressions failed
            if(lineNumber == "n/a"){ return }
            
            // Create reference variable to determine correct handling
            var type = "n/a"
            var indicator = "n/a"
            
            if(inboundOrOutbound=="I" || inboundOrOutbound=="O"){
                
                type = inboundOrOutbound
            
            }else{
                
                type = detailedType
            
            }
            
            if(startOrEnd=="S" || startOrEnd=="E"){
                
                indicator = startOrEnd
                
            }else{
                
                indicator = ""
                
            }
            
            // create filter to use with determining call types below
            var filter = type + indicator;
            
            // --
            switch lineNumber {
                
            case "01":
                
                //-------------------- LINE 1 -------------------------
                
                switch filter {
                
                case "R":
                    
                    //-------------------------------------------------
                    // Line 1 ringing
                    //-------------------------------------------------
                    
                    // Change line 1 picture to ringing
                    
                    // Change background color of table row to green for incoming call
                    
                    // Show time on line 1 row
                    
                    // Show callerid (name & number)
                    
                    //-------------------------------------------------
                    
                    break
                    
                case "IS":
                    
                    //-------------------------------------------------
                    // Line 1 - inbound start record
                    //-------------------------------------------------
                    
                    // Change row background color to green for incoming call
                    
                    // Show time on line 1 row
                    
                    // Show callerid (name & number)
                    
                    break
                    
                case "F":
                    
                    //-------------------------------------------------
                    // Line 1 - off hook
                    //-------------------------------------------------
                    
                    // Change image to show phone off-hook
                    
                    break
                    
                case "N":
                    
                    //-------------------------------------------------
                    // Line 1 - on hook
                    //-------------------------------------------------
                    
                    // Change row background color back to idle
                    
                    // Change image back to not-ringing
                    
                    break
                    
                case "IE":
                    
                    //-------------------------------------------------
                    // Line 1 - inbound end record
                    //-------------------------------------------------
                    
                    // add your code if needed
                    
                    break
                    
                case "OS":
                    
                    //-------------------------------------------------
                    // Line 1 - outbound start record
                    //-------------------------------------------------
                    
                    // Change image to show phone off-hook
                    
                    // Change background color to blue for outbound call
                    
                    // Show time on line 1 row
                    
                    // Show callerid (name & number)
                    
                    break
                    
                case "OE":
                    
                    //-------------------------------------------------
                    // Line 1 - outbound end record
                    //-------------------------------------------------
                    
                    // add your code if needed
                    
                    break
                    
                default:
                    return
                }
                
                
                break
                
            case "02":
                
                //-------------------- LINE 2 -------------------------
                
                
                
                break
                
            case "03":
                
                //-------------------- LINE 3 -------------------------
                
                
                
                break
                
            case "04":
                
                //-------------------- LINE 4 -------------------------
                
                
                
                break
                
                
            default:
                
                return
            }
            
            
            
        }
        else{
            
            // data from udp wasn't used
            
        }
        
        
        
    }

}

