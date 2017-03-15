//
//  DBManager.swift
//  iosSampleApp
//
//  Created by mac on 3/14/17.
//  CallerID.com
//

import UIKit

class DBManager: NSObject {

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
    
    // Make singleton
    static let shared: DBManager = DBManager()
    
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
                    "CREATE TABLE calls (id INTEGER PRIMARY KEY AUTOICREMENT NOT NULL," +
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
                        
                    "CREATE TABLE contacts (id INTEGER PRIMARY KEY AUTOICREMENT NOT NULL," +
                        "Name TEXT," +
                        "Number TEXT," +
                        "Address, " +
                        "City, " +
                        "State, " +
                        "Zip" +
                        ");"
                    
                    do {
                        try database.executeUpdate(creationQuery, values: nil)
                        created = true
                    }
                    catch {
                        print("Could not create tables.")
                        print(error.localizedDescription)
                    }
                    
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
                print(database.lastError(), database.lastErrorMessage())
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
                "\(name)," +
                "\(number)," +
                "\(address)," +
                "\(city)," +
                "\(state)," +
                "\(zip)" +
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
