//
//  DBManager.swift
//  iosSampleApp
//
//  Created by mac on 3/14/17.
//  CallerID.com
//

import UIKit

class DBManager: NSObject {
    
    // ------------------------------------------------------------
    // Setup database class for connecting/editing/closing database
    // ------------------------------------------------------------
    static let shared: DBManager = DBManager()

    
    //-------------------------------------------------------------
    // Variable storing for database use
    //-------------------------------------------------------------
    var line_1_last_number:String = "no calls"
    var line_2_last_number:String = "no calls"
    var line_3_last_number:String = "no calls"
    var line_4_last_number:String = "no calls"
    var line_selected_for_info = 1
    
    //----------------------------------------
    //         Getters and setters
    //----------------------------------------
    func setLineLastNumber(line:Int,number:String) {
        
        switch line {
        case 1:
            line_1_last_number=number
            break
            
        case 2:
            line_2_last_number=number
            break
            
        case 3:
            line_3_last_number=number
            break
            
        case 4:
            line_4_last_number=number
            break
            
        default:
            break
        }
        
    }
    
    func setLineSelected(line:Int){
        line_selected_for_info = line
    }
    
    func getLineSelected() -> Int {
        return line_selected_for_info
    }
    
    func getLineLastNumber(line:Int) -> String {
        
        switch line {
        
        case 1:
            return line_1_last_number
            
        case 2:
            return line_2_last_number
            
        case 3:
            return line_3_last_number
            
        case 4:
            return line_4_last_number
            
        default:
            return "no calls"
        }
        
    }
    
    //-------------------------------------------------------------
    //                      DATABASE FUNCTIONS
    //-------------------------------------------------------------
    
    // Setup field constants for accessing fields in database
    let field_datetime = "DateTime"
    let field_line = "Line"
    let field_type = "Type"
    let field_indicator = "Indicator"
    let field_duration = "Duration"
    let field_checksum = "Checksum"
    let field_rings = "Rings"
    let field_number = "Number"
    let field_name = "Name"
    let field_address = "Address"
    let field_city = "City"
    let field_state = "State"
    let field_zip = "Zip"
    
    
    // Needed database variables
    let databaseFileName = "database.sqlite"
    var pathToDatabase: String!
    var database: FMDatabase!
    
    // Initalize location of database
    override init() {
        
        super.init()
        
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
        
    }
    
    // ----------------------------------------------------------
    //                    Database functions
    // ----------------------------------------------------------
    // Create the database
    func createDatabase() -> Bool {
        var created = false
        
        if !FileManager.default.fileExists(atPath: pathToDatabase) {
            database = FMDatabase(path: pathToDatabase!)
            
            if database != nil {
                // Open the database.
                if database.open() {
                    
                    // Create tables with needed formats
                    let creationQuery =
                    "CREATE TABLE calls (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL," +
                        "DateTime TEXT," +
                        "Line TEXT," +
                        "Type TEXT," +
                        "Indicator TEXT," +
                        "Duration TEXT," +
                        "Checksum TEXT," +
                        "Rings TEXT," +
                        "Number TEXT," +
                        "Name TEXT" +
                        ");" +
                        
                    "CREATE TABLE contacts (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL," +
                        "Name TEXT," +
                        "Number TEXT," +
                        "Address, " +
                        "City, " +
                        "State, " +
                        "Zip" +
                        ");"
                    
                    
                    database.executeStatements(creationQuery)
                    created = true
                    
                    // At the end close the database.
                    database.close()
                }
                else {
                    print("Could not open the database.")
                }
            }
        }
        
        return created
    }
    
    // ----------------------------------------------------------
    //                       Open Database
    // ----------------------------------------------------------
    
    func openDatabase() -> Bool {
        if database == nil {
            if FileManager.default.fileExists(atPath: pathToDatabase) {
                database = FMDatabase(path: pathToDatabase)
            }
        }
        
        if database != nil {
            if database.open() {
                return true
            }
        }
        
        return false
    }
    
    // ----------------------------------------------------------
    //                     Execute a sql query
    // ----------------------------------------------------------
    
    func executeQuery(query: String) -> Bool {
        
        if(openDatabase()){
            
            if !database.executeStatements(query) {
                print("Query Failed: " + query)
                let errorString = (database.lastError(), database.lastErrorMessage())
                print(errorString)
                return false
            }
            
            database.close()
            return true
        }
        
        return false
        
    }
    
    // ----------------------------------------------------------
    //                 Get resultset from query
    // ----------------------------------------------------------
    
    func getResults(query: String, values: [String]) -> FMResultSet {
        
        if(openDatabase()){
            do {
                let results = try database.executeQuery(query, values: values)
                return results
            } catch {
                print("Get resultset failed.")
            }
        }
        
        return FMResultSet()
        
    }
    
    // ----------------------------------------------------------
    //             Insert/Update new data for contact
    // ----------------------------------------------------------
    
    func insertOrUpdateContact(name: String,
                          number: String,
                          address: String,
                          city: String,
                          state: String,
                          zip: String) -> Bool {
        
        // Check if already in database before adding
        let contactInfo = checkCallerIdForMatch(number: number)
        
        var query = ""
        if(contactInfo[0]=="not found"){
            
            // Contact not found, so add it now
            query = "INSERT INTO contacts (" +
                "\(field_name)," +
                "\(field_number)," +
                "\(field_address)," +
                "\(field_city)," +
                "\(field_state)," +
                "\(field_zip)" +
                "" +
                ") VALUES (" +
                "" +
                "'\(name)'," +
                "'\(number)'," +
                "'\(address)'," +
                "'\(city)'," +
                "'\(state)'," +
                "'\(zip)'" +
                ");"
            
        }
        else{
        
            // Contact was found, so update it
            query = "UPDATE contacts SET " +
                "\(field_name) = '\(name)'," +
                "\(field_address) = '\(address)'," +
                "\(field_city) = '\(city)'," +
                "\(field_state) = '\(state)'," +
                "\(field_zip) = '\(zip)'" +
                " " +
                "WHERE \(field_number) = '\(number)';"
            
        }
        
        return executeQuery(query: query)
        
        
    }
    
    // ----------------------------------------------------------
    //     Check CallerId for match and return info if found
    // ----------------------------------------------------------
    
    func checkCallerIdForMatch(number: String) -> [String] {
        
        let results = getResults(query: "SELECT * FROM contacts WHERE \(field_number)=? ;", values: [number])
        
        var name = "not found"
        var address = "not found"
        var city = "not found"
        var state = "not found"
        var zip = "not found"
        
        while results.next() {
            
            name = results.string(forColumn: field_name)
            address = results.string(forColumn: field_address)
            city = results.string(forColumn: field_city)
            state = results.string(forColumn: field_state)
            zip = results.string(forColumn: field_zip)
            
        }
        
        return [name,address,city,state,zip]
        
    }
    
    
}
