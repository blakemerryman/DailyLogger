// Playground - noun: a place where people can play

// MARK: - Constants

import Foundation










func checkDirectoryAndCreateFileForFileManager(fileManager: NSFileManager, directoryToCheck directory: String, fileToCreate fileName: String) -> Bool {
    
    if fileManager.fileExistsAtPath(directory) {
        
        let filePath = directory + "/\(fileName)"
        
        if !fileManager.fileExistsAtPath(filePath) {
            
            // Create an empty file!
            
            var writeError: NSError? = nil
            ("" as NSString).writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: &writeError)
            
            if writeError != nil {
                println(writeError)
                return false
            }
        }
        return true
    }
    return false
}

//let logDirectory = NSHomeDirectoryForUser(NSUserName()).stringByAppendingPathComponent("Desktop")
//let fileManager = NSFileManager.defaultManager()
//let logReadyForWriting = checkDirectoryAndCreateFileForFileManager(fileManager, directoryToCheck: logDirectory, fileToCreate: "test1.md")







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

//let today = NSDate()
//let filename = buildFileNameForDate(today)
//let header = buildLogHeader(author: "Blake Merryman", forDate: today)











let kError           = "Key: Errors are stored here. Should Check first."
let kFlag            = "Key: Console Flag (normal version)"
let kFlagShort       = "Key: Console Flag (short version)"
let kArguments       = "Key: Console Argument(s)"
let kArgumentCount   = "Key: Console Flag's argument count"
let kAcceptsFlagless = "Key: Console can accept arguments without a flag"

// MARK: -

class ArgumentParser {
    
    // PUBLIC
    
    private(set) var parsedInput: [String:String]!
    
    init(flagsToParse: [[String:Any]]!, inputToParse: [String]!) {
        println("AP: init")
        parsedInput = parseInput(inputToParse, withFlags: flagsToParse)
    }
    
    // PRIVATE
    
    private func parseInput(input: [String]!, withFlags flags: [[String:Any]]!) -> [String:String] {
        
        var flagBuffer      = ""
        var findingFlagArgs = false
        var flagArgsCount   = 0
        var flagArgsBuffer  = ""
        
        var parsed = ["":""]
        
        for argument in input {
            
            if findingFlagArgs {
                
                if flagArgsCount > 0 {
                    
                    flagArgsBuffer += argument as String
                    flagArgsCount--
                
                } else {
                    
                    parsed[flagBuffer] = flagArgsBuffer
                    
                    findingFlagArgs = false
                    flagBuffer      = ""
                    flagArgsBuffer  = ""
                }
                
            } else {
               
                for flag in flags {
                    if argument == flag[kFlag] as String || argument == flag[kFlagShort] as String {
                        if flag[kArgumentCount] as Int > 0 {
                            flagBuffer = argument
                            findingFlagArgs = true
                            flagArgsCount = flag[kArgumentCount] as Int
                        } else {
                            parsed[argument] = ""
                        }
                    }
                }
            }
        }
        
        // Check buffer for stragglers...
        if !flagBuffer.isEmpty {
            parsed[flagBuffer] = flagArgsBuffer
        }
        
        parsed[""] = nil // remove empty placeholder
        
        return parsed
    }
    
}

// MARK: - Testing...

//let userInput1 = ["./DailyLogger.swift", "--help"]
//let userInput2 = ["./DailyLogger.swift","--append","This is some text"]
//
//let myFlags: [[String:Any]] = [
//    [kFlag: "--help", kFlagShort: "-h", kArgumentCount: 0],
//    [kFlag: "--list", kFlagShort: "-l", kArgumentCount: 0],
//    [kFlag: "--append", kFlagShort: "-a", kArgumentCount: 1]
//]
//
//let parser = ArgumentParser(flagsToParse: myFlags, inputToParse: userInput2)
//println(parser.parsedInput)


// --------------------------------------------------
