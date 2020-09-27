//
//  Canvas.swift
//  Planner
//
//  Created by Andrea Clare Lam on 02/09/2020.
//  Copyright © 2020 Andrea Clare Lam. All rights reserved.
//
// Database for notes/drawings

import Foundation
import SQLite3

struct Canvas {
    let id: Int
    var date: Date
    var drawing: Data
}

class CanvasManager {
    
    var database: OpaquePointer!
    
    // allow class to be called
    static let main = CanvasManager()
    private init() {
    }
    
    // Function to connect database
    func connect() {
        
        // if database already exists
        if database != nil {
            return
        }
        
        // Create path in user's device
        do {
            let databaseURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("drawings.sqlite3")
            
            // open db file!!!!
            if sqlite3_open(databaseURL.path, &database) != SQLITE_OK {
                print("Could not open database")
            }
                                    
            // create table
            if sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS drawings (date TEXT, drawing BLOB)", nil, nil, nil) != SQLITE_OK {
                print("Could not create table")
            }
        }
        catch _ {
            print("Could not create database")
        }
        
    }
    
    // Function to create new drawing
    // return row id of newly inserted row
    func create(date: Date, drawing: Data) -> Int {
        connect()
        
        // prepare statment
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "INSERT INTO drawings (date, drawing) VALUES (?, ?)", -1, &statement, nil) != SQLITE_OK {
            print("Could not create (insert) query")
            return -1
        }
                
        // bind
        sqlite3_bind_text(statement, 1, NSString(string: dateToStringFormat(dateDate: date)).utf8String, -1, nil)
        let drawingPtr = dataToPtr(drawing: drawing)
        sqlite3_bind_blob(statement, 1, drawingPtr, -1, nil)
                
        // execute statement
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Could not execute insert statement")
            return -1
        }
        
        // Finalise statement
        sqlite3_finalize(statement)
        return Int(sqlite3_last_insert_rowid(database))
    }
    
    // Function to save drawing to database
    func save(canvas: Canvas) {
        connect()
        
        // prepare
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "UPDATE drawings SET date = ?, drawing = ? WHERE rowid = ?", -1, &statement, nil) != SQLITE_OK {
            print("Could not create (update) query")
        }
        
        // bind place holders
        sqlite3_bind_text(statement, 1, NSString(string:dateToStringFormat(dateDate: canvas.date)).utf8String, -1, nil)
        print("DRAWING SAVED: \(canvas.drawing)")
        let drawingPtr = dataToPtr(drawing: canvas.drawing)
        sqlite3_bind_blob(statement, 2, drawingPtr, -1, nil)
        sqlite3_bind_int(statement, 3, Int32(canvas.id))
        
        // execute
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Could not execute update statement")
        }
        
        // finalise
        sqlite3_finalize(statement)
    }
    
    // Function to delete drawing
    func delete(canvas: Canvas) {
        connect()
        
        // prepare
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "DELETE FROM drawings WHERE rowid = ?", -1, &statement, nil) != SQLITE_OK {
            print("Could not create (delete) query")
        }
        
        // bind
        sqlite3_bind_int(statement, 1, Int32(canvas.id))
        
        // execute
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Could not execute delete statement")
        }
        
        // finalise
        sqlite3_finalize(statement)
    }
    
    // Function to check if canvas for a certain date is already in the database
    func check(selectedDate: Date) -> [Canvas] {
        connect()
        
        var result: [Canvas] = []
        // prepare
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "SELECT rowid, date, drawing FROM drawings WHERE date = ?", -1, &statement, nil) != SQLITE_OK {
            print("Could not create (select) query")
            return []
        }
        
        // bind
        sqlite3_bind_text(statement, 1, NSString(string:dateToStringFormat(dateDate: selectedDate)).utf8String, -1, nil)
        
        // executes
        while sqlite3_step(statement) == SQLITE_ROW {
            
            // change string date into Date date
            let Date_date = stringToDateFormat(stringDate: String(cString: sqlite3_column_text(statement, 1)))
            // if canvas is empty
            if sqlite3_column_blob(statement, 2) != nil {
                let drawingPtr = sqlite3_column_blob(statement, 2)
                result.append(Canvas(id: Int(sqlite3_column_int(statement, 0)), date: Date_date, drawing: drawingPtr!.load(as: Data.self)))
                print("DRAWING NOT NIL")
            }
            else {
                let drawing = Data.init()
                result.append(Canvas(id: Int(sqlite3_column_int(statement, 0)), date: Date_date, drawing: drawing))
                print("DRAWING IS NIL")
            }
        }
        
        // finalise
        sqlite3_finalize(statement)
        

        
        return result
    }
    
    /* ------------------------------------------------------------------------- */
    
    // Function to turn string date into Date date
    func stringToDateFormat(stringDate: String) -> Date {
        let formatter = ISO8601DateFormatter()
        let dateDate = formatter.date(from: stringDate)
        return dateDate!
    }
    
    // Function to turn Date date to String date
    func dateToStringFormat(dateDate: Date) -> String {
        let formatter = ISO8601DateFormatter()
        let stringDate = formatter.string(from: dateDate)
        
        return stringDate
    }
    
    // Date to String to show users not to calculate or to save in database
    func dateToStringShow(dateDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let stringDate = formatter.string(from: dateDate)
        
        return stringDate
    }
    
    // Function to convert data to unsafe raw pointer
    func dataToPtr(drawing: Data) -> UnsafeRawPointer {
        let nsData = drawing as NSData
        let rawPtr = nsData.bytes
        return rawPtr
    }
}
