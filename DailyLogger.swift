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


// MARK: - Personal Preferences

// This log belongs to...
let loggersName = "Blake Merryman"

// Edit this log in the following application...
let textEditor = "Sublime Text 3.app"

// Store this log in the following directory (relative to current user's home directory)...
let logDirectory = NSHomeDirectoryForUser(NSUserName()).stringByAppendingPathComponent("Dropbox/DailyLog")

// --------------------------------------------------


// MARK: - Define & Grab UserInput

enum UserInputOptions: String {
    case Help        = "help"
    case Append      = "--append"
    case AppendShort = "-a"
    case List        = "--list"
    case ListShort   = "-l"
}  

let arguments = Process.arguments

if arguments.count > 1 && arguments[1] == UserInputOptions.Help.rawValue {
    println("\n DailyLogger Help")
    println(" --------------------------------------------------")
    println("\n COMMANDS:")
    println("   --append (short -a): appends the trailing text to the end of daily log file")
    println("\n NOTES:")
    println("   - If you use punctuation in an appended note, make sure to properly escape.")
    println("   - ")
    println("")
} 
else {
    
    // MARK: - Date & Log Header

    // Handle Today's Date

    let today = NSDate()

    // Date Formatting for header...

    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
    let todaysFullDate = dateFormatter.stringFromDate(today)

    // Date Components for file name...

    let componentsToGrab: NSCalendarUnit = .YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit
    let dateComponents = NSCalendar.currentCalendar().components( componentsToGrab, fromDate: today)

    let numberFormatter = NSNumberFormatter()
    numberFormatter.paddingCharacter = "0"
    numberFormatter.minimumIntegerDigits = 2

    let year  = dateComponents.year
    let month = numberFormatter.stringFromNumber(dateComponents.month)!
    let day   = numberFormatter.stringFromNumber(dateComponents.day)!

    // Build Header for log file
    let logHeader = "# Daily Log of \(loggersName)\n  *\(todaysFullDate)*\n\n--------------------------------------------------"


    // MARK: - File Handling

    let fileManager = NSFileManager.defaultManager()

    // Check that our directory exists...

    if fileManager.fileExistsAtPath(logDirectory) {    

        let filePath = logDirectory + "/\(year)-\(month)-\(day)-DL.md"

        // Check if file already exists...
        if !fileManager.fileExistsAtPath(filePath) {

            // File does not yet exist so create it...
            var writeError: NSError? = nil
            (logHeader as NSString).writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: &writeError)
            
        } 


        // LIST
        if arguments.count > 1 && (arguments[1] == UserInputOptions.List.rawValue || arguments[1] == UserInputOptions.ListShort.rawValue) {
            
            // Get current content of file & print...
            var readError: NSError? = nil
            println("\n\nLog Entry: \(filePath)")
            print(NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: &readError)!)
            println("\n\n") // Formatting
        
        } 
        // APPEND
        else if arguments.count > 1 && (arguments[1] == UserInputOptions.Append.rawValue || arguments[1] == UserInputOptions.AppendShort.rawValue) {
            
            var newLogEntry = "\n\n"

            for (index,argument) in enumerate(arguments) {
                if index > 1 {
                    newLogEntry += argument + " "
                }
            }

            // Get current content of file & append...
            var readError: NSError? = nil
            var fileContents = NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: &readError)! as String

            fileContents += newLogEntry

            // Write it all back to the disk!
            var writeError: NSError? = nil
            (fileContents as NSString).writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: &writeError)
        
        }
        // NONE... So OPEN
        else {

            // MARK: - Open File in Text Editor of Choice

            NSWorkspace.sharedWorkspace().openFile(filePath, withApplication: textEditor, andDeactivate: true)
        }
    } 
    
    else {
        println("Error: Directory Does Not Exist")
    }

}


