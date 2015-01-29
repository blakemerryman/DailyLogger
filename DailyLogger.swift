#!/usr/bin/env xcrun swift -F /Library/Frameworks

/*

DailyLogger.swift

Blake Merryman

Created January 5, 2015

This script creates a new log file for each day stored in a user specified 
directory. It has multiple user options for various functionality
(like appending to current log or listing to the console).

*/

import Foundation
import AppKit
import BMParse



// MARK: - Personal Preferences

let authorName = "Blake Merryman"
let textEditor = "Sublime Text 3.app"
let logDirectory = NSHomeDirectoryForUser(NSUserName()).stringByAppendingPathComponent("Dropbox/DailyLog")
let pathToHelpFile = NSHomeDirectoryForUser(NSUserName()).stringByAppendingPathComponent("Dropbox/Developer/MyTools/DailyLogger") + "/help.txt"

// TODO: Get path of this script so help.txt can be linked w/relative path



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
let logHeader   = buildLogHeader(author: authorName, forDate: today)
let fileManager = NSFileManager.defaultManager()
let logIsReady  = checkDirectoryAndCreateFileForFileManager(fileManager, directoryToCheck: logDirectory, fileToCreate: logFilename, withContents: logHeader)

let fullPathToFile = "\(logDirectory)/\(logFilename)"


// MARK: - Define Options for User Input
// Each option has a long- & short- flag along with a completion handler to process its result
// (and any errors) processed from user input.


// MARK: - Option: Print Help File To Console

let help = Option(longFlag: "--help", shortFlag: "-h") { (result: Result!, error: NSError!) in 

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
}


// MARK: - Option: Open Current Log File

let open = Option(longFlag: "--open", shortFlag: "-o") { (result: Result!, error: NSError!) in 

    if error != nil {
        println("Error performing completion handler! \(error)")
    } 
    else {
        NSWorkspace.sharedWorkspace().openFile("\(logDirectory)/\(logFilename)", withApplication: textEditor, andDeactivate: true)
    }
}


// MARK: - Option: List Current Log to Console

let list = Option(longFlag: "--list", shortFlag: "-l") { (result: Result!, error: NSError!) in 

    if error != nil {
        println("Error performing completion handler! \(error)")
    } 
    else {
        // Print the help file to the console using the cat command
        let printHelpTask = NSTask()
        printHelpTask.launchPath = "/bin/cat"
        printHelpTask.arguments = [fullPathToFile]
        printHelpTask.launch()
    }
}


// MARK: - Option: Append User Input to Current Log File

let append = Option(longFlag: "--append", shortFlag: "-a") { (result: Result!, error: NSError!) in
    
    if error != nil {
        println("Error performing completion handler! \(error)")
    } 
    else {

        if let arguments = result.arguments {
            
            var newLogEntry = "\n" // front padding

            for argument in arguments {
                newLogEntry += argument + " "
            }

            newLogEntry += "\n" // end padding

            // Get current content of file & append...
            var readError: NSError? = nil
            var fileContents = NSString(contentsOfFile: fullPathToFile, encoding: NSUTF8StringEncoding, error: &readError)! as String

            fileContents += newLogEntry

            // Write it all back to the disk!
            var writeError: NSError? = nil
            (fileContents as NSString).writeToFile(fullPathToFile, atomically: true, encoding: NSUTF8StringEncoding, error: &writeError)
        }
    }
}


// ----------------------------------------------------------------------------------------------------
// MARK: - Load Options & Process User Input

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
