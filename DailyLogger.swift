#!/usr/bin/env xcrun swift -F /Library/Frameworks

/*

DailyLogger.swift

Blake Merryman

Created January 5, 2015

This script application creates a new log file for use in Blake Merryman's 
Daily Log folder. It accepts no input and outputs a properly formatted
(including basic boiler plate & correctly named file) markdown (.md) file
in the correct directory.

*/

import Foundation
import AppKit
import CLParse


// MARK: - Personal Preferences

// This log belongs to...
let loggersName = "Blake Merryman"

// Edit this log in the following application...
let textEditor = "Sublime Text 3.app"

// Store this log in the following directory (relative to current user's home directory)...
let logDirectory = NSHomeDirectoryForUser(NSUserName()).stringByAppendingPathComponent("Dropbox/DailyLog")
let pathToHelpFile = NSHomeDirectoryForUser(NSUserName()).stringByAppendingPathComponent("Dropbox/Developer/MyTools/DailyLogger") + "/help.txt"


// ----------------------------------------------------------------------------------------------------


// MARK: - Utility Functions

func buildFileNameForDate(date: NSDate) -> String {
    
    // Handle Today's Date
    
    let today = NSDate()
    
    // Date Components for file name...
    
    let componentsToGrab: NSCalendarUnit = .YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit
    let dateComponents = NSCalendar.currentCalendar().components(componentsToGrab, fromDate: today)
    
    let numberFormatter = NSNumberFormatter()
    numberFormatter.paddingCharacter = "0"
    numberFormatter.minimumIntegerDigits = 2
    
    let year  = numberFormatter.stringFromNumber(dateComponents.year)!
    let month = numberFormatter.stringFromNumber(dateComponents.month)!
    let day   = numberFormatter.stringFromNumber(dateComponents.day)!
    
    return "\(year)-\(month)-\(day)-DL.md"
}

func buildLogHeader(#author: String, forDate date: NSDate) -> String {
    
    // Handle Today's Date
    
    let today = NSDate()
    
    // Date Formatting for header...
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
    let todaysFullDate = dateFormatter.stringFromDate(today)
    
    return"# Daily Log of \(author)\n  *\(todaysFullDate)*\n\n--------------------------------------------------"
}

func checkDirectoryAndCreateFileForFileManager(fileManager: NSFileManager, directoryToCheck directory: String, fileToCreate fileName: String, withContents fileContents: String) -> Bool {
    
    if fileManager.fileExistsAtPath(directory) {
        
        let filePath = directory + "/\(fileName)"
        
        if !fileManager.fileExistsAtPath(filePath) {
            
            // Create an empty file!
            
            var writeError: NSError? = nil
            (fileContents as NSString).writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: &writeError)
            
            if writeError != nil {
                println("Error: Could not create file... \(writeError)")
                return false
            }
        }
        return true // Only returns TRUE if file is created successfully OR file already exists
    }
    return false
}


// MARK: - Setting Up The Log File For Usage...

let today       = NSDate()
let logFilename = buildFileNameForDate(today)
let logHeader   = buildLogHeader(author: loggersName, forDate: today)
let fileManager = NSFileManager.defaultManager()
let logIsReady  = checkDirectoryAndCreateFileForFileManager(fileManager, directoryToCheck: logDirectory, fileToCreate: logFilename, withContents: logHeader)

let fullPathToFile = "\(logDirectory)/\(logFilename)"


// ----------------------------------------------------------------------------------------------------


// MARK: - Define Options for User Input

// Each option has a long- & short- flag value along with a completion handler to handle its results (and any errors) processed from user input.

let help = Option(longFlag: "--help", shortFlag: "-h", completionHandler: { (result: Result!, error: NSError!) in 

    if error != nil {
        println("Error performing completion handler! \(error)")
    } 
    else {
        // Print the help file to the console using the cat command
        let printHelpTask = NSTask()
        printHelpTask.launchPath = "/bin/cat"
        printHelpTask.arguments = [pathToHelpFile]
        printHelpTask.launch()
    }
})

let open = Option(longFlag: "--open", shortFlag: "-o", completionHandler: { (result: Result!, error: NSError!) in 

    if error != nil {
        println("Error performing completion handler! \(error)")
    } 
    else {
        NSWorkspace.sharedWorkspace().openFile("\(logDirectory)/\(logFilename)", withApplication: textEditor, andDeactivate: true)
    }
})

let list = Option(longFlag: "--list", shortFlag: "-l", completionHandler: { (result: Result!, error: NSError!) in 

    if error != nil {
        println("Error performing completion handler! \(error)")
    } 
    else {
        println("Test - Listing") 
    }
})

let append = Option(longFlag: "--append", shortFlag: "-a", completionHandler: { (result: Result!, error: NSError!) in
    
    if error != nil {
        println("Error performing completion handler! \(error)")
    } 
    else {
        println("Test - Appending") 
    }
})


// ----------------------------------------------------------------------------------------------------


// MARK: - Process User Input

if logIsReady {

    let logOptions = [help, open, list, append]
    let myParser = Parser(options: logOptions)

    if let results = myParser.parseArguments(Process.arguments) {
        // If we received arguments, each option's completion handler with perform the appropriate action!
        println("DailyLogger: Arguments processed!")
    }
    else {
        // If we do not receive any arguments from the user...
        println("\n     DailyLogger currently requires some option to be specified. Use \"--help\" (or \"-h\") for more information.\n")
    }
}
else {
    println("DailyLogger Error: Issues while preparing log file! Check to ensure that your destination path is correct and exists.")
}
