//
//  ViewController.swift
//  iosSampleApp
//
//  Created by mac on 3/13/17.
//  CallerID.com
//

import UIKit
import CocoaAsyncSocket
import  UserNotifications
import UserNotificationsUI

class ViewController: UITableViewController, GCDAsyncUdpSocketDelegate {

    // ----------------------------------------------------------------------------
    //        Setup UI elements to allow for editing
    // ----------------------------------------------------------------------------
    
    // ------------------------------------------------------
    //                      Main View
    // ------------------------------------------------------
    // Phone status images
    @IBOutlet weak var line_1_image: UIImageView!
    @IBOutlet weak var line_2_image: UIImageView!
    @IBOutlet weak var line_3_image: UIImageView!
    @IBOutlet weak var line_4_image: UIImageView!
    
    // Database status images
    @IBOutlet weak var line_1_database_image: UIImageView!
    @IBOutlet weak var line_2_database_image: UIImageView!
    @IBOutlet weak var line_3_database_image: UIImageView!
    @IBOutlet weak var line_4_database_image: UIImageView!
    
    // Row backgrounds
    @IBOutlet weak var line_1_row: UIView!
    @IBOutlet weak var line_2_row: UIView!
    @IBOutlet weak var line_3_row: UIView!
    @IBOutlet weak var line_4_row: UIView!
    
    // Text on rows
    @IBOutlet weak var line_1_text: UILabel!
    @IBOutlet weak var line_2_text: UILabel!
    @IBOutlet weak var line_3_text: UILabel!
    @IBOutlet weak var line_4_text: UILabel!
    
    // ------------------------------------------------------
    //                      Info View
    // ------------------------------------------------------
    @IBOutlet weak var info_name: UITextField!
    @IBOutlet weak var info_number: UITextField!
    @IBOutlet weak var info_address: UITextField!
    @IBOutlet weak var info_city: UITextField!
    @IBOutlet weak var info_state: UITextField!
    @IBOutlet weak var info_zip: UITextField!
    
    // ----------------------------------------------------------------------------
    
    // -------------------------------------------------------------------------
    //                      Segues to the contacts view
    // -------------------------------------------------------------------------
    
    @IBAction func line_1_move_to_info(_ sender: UITapGestureRecognizer) {
    
        if(DBManager.shared.getLineLastNumber(line: 1) != "no calls"){
            
            DBManager.shared.setLineSelected(line: 1)
            performSegue(withIdentifier: "segue_main_to_info", sender: self)
            
        }
    
    }
    
    @IBAction func line_2_move_to_info(_ sender: UITapGestureRecognizer) {
    
        if(DBManager.shared.getLineLastNumber(line: 2) != "no calls"){
            
            DBManager.shared.setLineSelected(line: 2)
            performSegue(withIdentifier: "segue_main_to_info", sender: self)
            
        }
    
    }
    
    @IBAction func line_3_move_to_info(_ sender: UITapGestureRecognizer) {
    
        if(DBManager.shared.getLineLastNumber(line: 3) != "no calls"){
            
            DBManager.shared.setLineSelected(line: 3)
            performSegue(withIdentifier: "segue_main_to_info", sender: self)
            
        }
    
    }
    
    @IBAction func line_4_move_to_info(_ sender: UITapGestureRecognizer) {
    
        if(DBManager.shared.getLineLastNumber(line: 4) != "no calls"){
            
            DBManager.shared.setLineSelected(line: 4)
            performSegue(withIdentifier: "segue_main_to_info", sender: self)
            
        }
    
    }
    
    // ------------------------------------------------------------------------
    //                   Loading and moving between views
    // ------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create database if not already created
        if(DBManager.shared.createDatabase()){
            // Database created
        }
        else{
            // Database failed to create
        }
        
        // If loading main to info screen
        if(info_number != nil){
            
            // Load info into textfields
            populateInfoFromDatabase()
            
            // Add event handlers for textfields
            info_name.addTarget(self, action: #selector(updateInfoInDataBase(textField:)), for: .editingDidEnd)
            info_address.addTarget(self, action: #selector(updateInfoInDataBase(textField:)), for: .editingDidEnd)
            info_state.addTarget(self, action: #selector(updateInfoInDataBase(textField:)), for: .editingDidEnd)
            info_state.addTarget(self, action: #selector(updateInfoInDataBase(textField:)), for: .editingDidEnd)
            info_zip.addTarget(self, action: #selector(updateInfoInDataBase(textField:)), for: .editingDidEnd)
            
        }
        
        // -------------------------------------------------
        
        // Start UDP server to listen to CallerID.com port (3520)
        startServer()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If coming back from info screen try to update database images
        if(line_1_database_image != nil){
            updateDatabaseImages()
        }
        
    }
    
    func updateDatabaseImages(){
        
        // -------------------------------------------------
        //  Set database images to reflect database changes
        // -------------------------------------------------
        
        if(DBManager.shared.getChangeToIdle(number: DBManager.shared.getLineLastNumber(line: 1))){
            line_1_database_image.image = UIImage(named: "contacts.png")
        }
        
        if(DBManager.shared.getChangeToIdle(number: DBManager.shared.getLineLastNumber(line: 2))){
            line_2_database_image.image = UIImage(named: "contacts.png")
        }
        
        if(DBManager.shared.getChangeToIdle(number: DBManager.shared.getLineLastNumber(line: 3))){
            line_3_database_image.image = UIImage(named: "contacts.png")
        }
        
        if(DBManager.shared.getChangeToIdle(number: DBManager.shared.getLineLastNumber(line: 4))){
            line_4_database_image.image = UIImage(named: "contacts.png")
            
        }
        
        // Reset all change variables
        DBManager.shared.setChangeToIdle(number: DBManager.shared.getLineLastNumber(line: 1), value: false)
        DBManager.shared.setChangeToIdle(number: DBManager.shared.getLineLastNumber(line: 2), value: false)
        DBManager.shared.setChangeToIdle(number: DBManager.shared.getLineLastNumber(line: 3), value: false)
        DBManager.shared.setChangeToIdle(number: DBManager.shared.getLineLastNumber(line: 4), value: false)
        
        // -------------------------------------------------
        
    }
    
    func updateInfoInDataBase(textField: UITextField){
        
        if(DBManager.shared.insertOrUpdateContact(name: info_name.text!,
                                               number: info_number.text!,
                                               address: info_address.text!,
                                               city: info_city.text!,
                                               state: info_state.text!,
                                               zip: info_zip.text!)){
            // Worked
            print("Inserted")
            
            // Set variable to change main view image to 'found contact'
            DBManager.shared.setChangeToIdle(number: info_number.text!, value: true)
            
        }
        else{
            
            // Failed toupdate
            print("Failed to insert")
            
        }
        
    }
    
    // -----------------------------------------------------------------------------
    //   Load in all known info for the number last received on selected line number
    // -----------------------------------------------------------------------------
    
    func populateInfoFromDatabase(){
        
        // Get the last received number for the selected line
        let number = DBManager.shared.getLineLastNumber(line: DBManager.shared.getLineSelected())
        let name = DBManager.shared.getLineLastName(line:DBManager.shared.getLineSelected())
        
        // Check database for contact with number selected
        var dbResult = DBManager.shared.checkCallerIdForMatch(number: number)
        
        // If number not found then populate info screen with <insert info>
        if(dbResult[0] == "not found"){
            
            info_name.text = name
            info_number.text = number
            info_address.text = "add info"
            info_city.text = "add info"
            info_state.text = "add info"
            info_zip.text = "add info"
            
            return
            
        }
        else{
            
            info_name.text = dbResult[0]
            info_number.text = number
            info_address.text = dbResult[1]
            info_city.text = dbResult[2]
            info_state.text = dbResult[3]
            info_zip.text = dbResult[4]
            
            return
            
        }
        
    }

    // --------------------------------------------------------------------------------------
    //                    ALL UDP LOWER LEVEL CODE
    // --------------------------------------------------------------------------------------
    
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
    
    // --------------------------------------------------------------------------------------
    
    // -------------------------------------------------------------------------
    //                     Receive data from a UDP broadcast
    // -------------------------------------------------------------------------
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        if let udpRecieved = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            
            // parse and handle udp data----------------------------------------------
            
            // declare used variables for matching
            var lineNumber = "n/a"
            var startOrEnd = "n/a"
            var inboundOrOutbound = "n/a"
            //var duration = "n/a"
            //var ckSum = "B"
            //var callRing = "n/a"
            var callTime = "01/01 0:00:00"
            var phoneNumber = "n/a"
            var callerId = "n/a"
            var detailedType = "n/a"
            
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
                        //duration = udpRecieved.substring(with: result!.rangeAt(4))
                        //ckSum = udpRecieved.substring(with: result!.rangeAt(5))
                        //callRing = udpRecieved.substring(with: result!.rangeAt(6)) + udpRecieved.substring(with: result!.rangeAt(7))
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
            
            // Update phone number variables for searching
            // Also update database image based on lookup
            if(phoneNumber != "n/a"){
               
                let lineNum = Int(lineNumber)
                DBManager.shared.setLineLastNumber(line: lineNum!, number: phoneNumber)
                DBManager.shared.setLineLastName(line: lineNum!, name: callerId)
                
                var dbResults = DBManager.shared.checkCallerIdForMatch(number: phoneNumber)
                
                if(dbResults[0] != "not found"){
                    
                    // -----------------------------------
                    //   Contact was found in database
                    // -----------------------------------
                    
                    // Update to show contact info in database instead of callerid
                    callerId = dbResults[0]
                    
                    // Update database image
                    switch lineNumber {
                    
                    case "01":
                        line_1_database_image.image = UIImage(named: "contacts.png")
                        break
                        
                    case "02":
                        line_2_database_image.image = UIImage(named: "contacts.png")
                        break
                        
                    case "03":
                        line_3_database_image.image = UIImage(named: "contacts.png")
                        break
                        
                    case "04":
                        line_4_database_image.image = UIImage(named: "contacts.png")
                        break
                        
                        
                    default:
                        break
                    }
                    
                }
                else{
                    
                    // -----------------------------------
                    //  Contact was not found in database
                    // -----------------------------------
                    
                    switch lineNumber {
                        
                    case "01":
                        line_1_database_image.image = UIImage(named: "contacts_add.png")
                        break
                        
                    case "02":
                        line_2_database_image.image = UIImage(named: "contacts_add.png")
                        break
                        
                    case "03":
                        line_3_database_image.image = UIImage(named: "contacts_add.png")
                        break
                        
                    case "04":
                        line_4_database_image.image = UIImage(named: "contacts_add.png")
                        break
                        
                        
                    default:
                        break
                    }
                    
                }
                
            }
            
            // Create reference variable to determine correct handling -----------
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
            
            // -------------------------------------------------------------------
            
            // create filter to use with determining call types below
            let filter = type + indicator;
            
            // ----------
            
            // Pad phone number and callerid
            phoneNumber = phoneNumber.padding(toLength: 18, withPad: " ", startingAt: 0)
            callerId = callerId.padding(toLength: 20, withPad: " ", startingAt: 0)
            
            // ---------
            
            switch lineNumber {
                
            case "01":
                
                //-------------------- LINE 1 -------------------------
                
                switch filter {
                
                case "R":
                    
                    //-------------------------------------------------
                    // Line 1 ringing
                    //-------------------------------------------------
                    
                    // Change line 1 picture to ringing
                    line_1_image.image = UIImage(named: "ring.png")
                    
                    // Change background color of table row to green for incoming call
                    line_1_row.backgroundColor = #colorLiteral(red: 0.0460288967, green: 0.6721785946, blue: 0.06633104274, alpha: 1)
                    
                    break
                    
                case "IS":
                    
                    //-------------------------------------------------
                    // Line 1 - inbound start record
                    //-------------------------------------------------
                    
                    // Display notification
                    sendNotification(line: 1, name: callerId, number: phoneNumber)
                    
                    // Change row background color to green for incoming call
                    line_1_row.backgroundColor = #colorLiteral(red: 0.0460288967, green: 0.6721785946, blue: 0.06633104274, alpha: 1)
                    
                    // Show time and callerid (name & number)
                    line_1_text.text = "01: " + callTime + "  " + phoneNumber + "  " + callerId
                    
                    break
                    
                case "F":
                    
                    //-------------------------------------------------
                    // Line 1 - off hook
                    //-------------------------------------------------
                    
                    // Change image to show phone off-hook
                    line_1_image.image = UIImage(named: "off-hook.png")
                    
                    break
                    
                case "N":
                    
                    //-------------------------------------------------
                    // Line 1 - on hook
                    //-------------------------------------------------
                    
                    // Change row background color back to idle
                    line_1_row.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                    
                    // Change image back to not-ringing
                    line_1_image.image = UIImage(named: "idle.png")
                    
                    break
                    
                case "IE":
                    
                    //-------------------------------------------------
                    // Line 1 - inbound end record
                    //-------------------------------------------------
                    
                    // Change row background color back to idle
                    line_1_row.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                    
                    // Change image back to not-ringing
                    line_1_image.image = UIImage(named: "idle.png")
                    
                    break
                    
                case "OS":
                    
                    //-------------------------------------------------
                    // Line 1 - outbound start record
                    //-------------------------------------------------
                    
                    // Change image to show phone off-hook
                    line_1_image.image = UIImage(named: "off-hook.png")
                    
                    // Change background color to blue for outbound call
                    line_1_row.backgroundColor = #colorLiteral(red: 0.328819922, green: 0.5575907389, blue: 0.6772587435, alpha: 1)
                    
                    // Show time and callerid (name & number)
                    line_1_text.text = "01: " + callTime + "  " + phoneNumber + "  " + callerId
                    
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
                
                switch filter {
                    
                case "R":
                    
                    //-------------------------------------------------
                    // Line 2 ringing
                    //-------------------------------------------------
                    
                    // Change line 2 picture to ringing
                    line_2_image.image = UIImage(named: "ring.png")
                    
                    // Change background color of table row to green for incoming call
                    line_2_row.backgroundColor = #colorLiteral(red: 0.0460288967, green: 0.6721785946, blue: 0.06633104274, alpha: 1)
                    
                    break
                    
                case "IS":
                    
                    //-------------------------------------------------
                    // Line 2 - inbound start record
                    //-------------------------------------------------
                    
                    // Display notification
                    sendNotification(line: 2, name: callerId, number: phoneNumber)
                    
                    // Change row background color to green for incoming call
                    line_2_row.backgroundColor = #colorLiteral(red: 0.0460288967, green: 0.6721785946, blue: 0.06633104274, alpha: 1)
                    
                    // Show time and callerid (name & number)
                    line_2_text.text = "02: " + callTime + "  " + phoneNumber + "  " + callerId
                    
                    break
                    
                case "F":
                    
                    //-------------------------------------------------
                    // Line 2 - off hook
                    //-------------------------------------------------
                    
                    // Change image to show phone off-hook
                    line_2_image.image = UIImage(named: "off-hook.png")
                    
                    break
                    
                case "N":
                    
                    //-------------------------------------------------
                    // Line 2 - on hook
                    //-------------------------------------------------
                    
                    // Change row background color back to idle
                    line_2_row.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                    
                    // Change image back to not-ringing
                    line_2_image.image = UIImage(named: "idle.png")
                    
                    break
                    
                case "IE":
                    
                    //-------------------------------------------------
                    // Line 2 - inbound end record
                    //-------------------------------------------------
                    
                    // Change row background color back to idle
                    line_2_row.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                    
                    // Change image back to not-ringing
                    line_2_image.image = UIImage(named: "idle.png")
                    
                    break
                    
                case "OS":
                    
                    //-------------------------------------------------
                    // Line 2 - outbound start record
                    //-------------------------------------------------
                    
                    // Change image to show phone off-hook
                    line_2_image.image = UIImage(named: "off-hook.png")
                    
                    // Change background color to blue for outbound call
                    line_2_row.backgroundColor = #colorLiteral(red: 0.328819922, green: 0.5575907389, blue: 0.6772587435, alpha: 1)
                    
                    // Show time and callerid (name & number)
                    line_2_text.text = "02: " + callTime + "  " + phoneNumber + "  " + callerId
                    
                    break
                    
                case "OE":
                    
                    //-------------------------------------------------
                    // Line 2 - outbound end record
                    //-------------------------------------------------
                    
                    // add your code if needed
                    
                    break
                    
                default:
                    return
                }

                
                break
                
            case "03":
                
                //-------------------- LINE 3 -------------------------
                
                switch filter {
                    
                case "R":
                    
                    //-------------------------------------------------
                    // Line 3 ringing
                    //-------------------------------------------------
                    
                    // Change line 3 picture to ringing
                    line_3_image.image = UIImage(named: "ring.png")
                    
                    // Change background color of table row to green for incoming call
                    line_3_row.backgroundColor = #colorLiteral(red: 0.0460288967, green: 0.6721785946, blue: 0.06633104274, alpha: 1)
                    
                    break
                    
                case "IS":
                    
                    //-------------------------------------------------
                    // Line 3 - inbound start record
                    //-------------------------------------------------
                    
                    // Display notification
                    sendNotification(line: 3, name: callerId, number: phoneNumber)
                    
                    // Change row background color to green for incoming call
                    line_3_row.backgroundColor = #colorLiteral(red: 0.0460288967, green: 0.6721785946, blue: 0.06633104274, alpha: 1)
                    
                    // Show time and callerid (name & number)
                    line_3_text.text = "03: " + callTime + "  " + phoneNumber + "  " + callerId
                    
                    break
                    
                case "F":
                    
                    //-------------------------------------------------
                    // Line 3 - off hook
                    //-------------------------------------------------
                    
                    // Change image to show phone off-hook
                    line_3_image.image = UIImage(named: "off-hook.png")
                    
                    break
                    
                case "N":
                    
                    //-------------------------------------------------
                    // Line 3 - on hook
                    //-------------------------------------------------
                    
                    // Change row background color back to idle
                    line_3_row.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                    
                    // Change image back to not-ringing
                    line_3_image.image = UIImage(named: "idle.png")
                    
                    break
                    
                case "IE":
                    
                    //-------------------------------------------------
                    // Line 3 - inbound end record
                    //-------------------------------------------------
                    
                    // Change row background color back to idle
                    line_3_row.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                    
                    // Change image back to not-ringing
                    line_3_image.image = UIImage(named: "idle.png")
                    
                    break
                    
                case "OS":
                    
                    //-------------------------------------------------
                    // Line 3 - outbound start record
                    //-------------------------------------------------
                    
                    // Change image to show phone off-hook
                    line_3_image.image = UIImage(named: "off-hook.png")
                    
                    // Change background color to blue for outbound call
                    line_3_row.backgroundColor = #colorLiteral(red: 0.328819922, green: 0.5575907389, blue: 0.6772587435, alpha: 1)
                    
                    // Show time and callerid (name & number)
                    line_3_text.text = "03: " + callTime + "  " + phoneNumber + "  " + callerId
                    
                    break
                    
                case "OE":
                    
                    //-------------------------------------------------
                    // Line 3 - outbound end record
                    //-------------------------------------------------
                    
                    // add your code if needed
                    
                    break
                    
                default:
                    return
                }

                
                
                
                break
                
            case "04":
                
                //-------------------- LINE 4 -------------------------
                
                switch filter {
                    
                case "R":
                    
                    //-------------------------------------------------
                    // Line 4 ringing
                    //-------------------------------------------------
                    
                    // Change line 4 picture to ringing
                    line_4_image.image = UIImage(named: "ring.png")
                    
                    // Change background color of table row to green for incoming call
                    line_4_row.backgroundColor = #colorLiteral(red: 0.0460288967, green: 0.6721785946, blue: 0.06633104274, alpha: 1)
                    
                    break
                    
                case "IS":
                    
                    //-------------------------------------------------
                    // Line 4 - inbound start record
                    //-------------------------------------------------
                    
                    // Display notification
                    sendNotification(line: 4, name: callerId, number: phoneNumber)
                    
                    // Change row background color to green for incoming call
                    line_4_row.backgroundColor = #colorLiteral(red: 0.0460288967, green: 0.6721785946, blue: 0.06633104274, alpha: 1)
                    
                    // Show time and callerid (name & number)
                    line_4_text.text = "04: " + callTime + "  " + phoneNumber + "  " + callerId
                    
                    break
                    
                case "F":
                    
                    //-------------------------------------------------
                    // Line 4 - off hook
                    //-------------------------------------------------
                    
                    // Change image to show phone off-hook
                    line_4_image.image = UIImage(named: "off-hook.png")
                    
                    break
                    
                case "N":
                    
                    //-------------------------------------------------
                    // Line 4 - on hook
                    //-------------------------------------------------
                    
                    // Change row background color back to idle
                    line_4_row.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                    
                    // Change image back to not-ringing
                    line_4_image.image = UIImage(named: "idle.png")
                    
                    break
                    
                case "IE":
                    
                    //-------------------------------------------------
                    // Line 4 - inbound end record
                    //-------------------------------------------------
                    
                    /// Change row background color back to idle
                    line_4_row.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                    
                    // Change image back to not-ringing
                    line_4_image.image = UIImage(named: "idle.png")
                    
                    break
                    
                case "OS":
                    
                    //-------------------------------------------------
                    // Line 4 - outbound start record
                    //-------------------------------------------------
                    
                    // Change image to show phone off-hook
                    line_4_image.image = UIImage(named: "off-hook.png")
                    
                    // Change background color to blue for outbound call
                    line_4_row.backgroundColor = #colorLiteral(red: 0.328819922, green: 0.5575907389, blue: 0.6772587435, alpha: 1)
                    
                    // Show time and callerid (name & number)
                    line_4_text.text = "04: " + callTime + "  " + phoneNumber + "  " + callerId
                    
                    break
                    
                case "OE":
                    
                    //-------------------------------------------------
                    // Line 4 - outbound end record
                    //-------------------------------------------------
                    
                    // add your code if needed
                    
                    break
                    
                default:
                    return
                }
                
                
                break
                
                
            default:
                
                return
            }
            
            
            
        }
        else{
            
            // data from udp wasn't used
            
        }
        
        
        
    }
    
    //-----------------------------------------------------------------------------------------
    // Notifications
    //-----------------------------------------------------------------------------------------
    
    func sendNotification(line:Int, name:String, number:String){
        
        let content = UNMutableNotificationContent()
        content.title = "Incoming Call on Line \(line)"
        content.body = "\(number)   \(name)"
        content.launchImageName = "ring.png"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "notify", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Error: \(error)")
            }
        }
        
    }
    
    //-----------------------------------------------------------------------------------------
    
}

