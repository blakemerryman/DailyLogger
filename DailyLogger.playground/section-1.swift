// Playground - noun: a place where people can play

// MARK: - Constants

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

let userInput1 = ["./DailyLogger.swift", "--help"]
let userInput2 = ["./DailyLogger.swift","--append","This is some text"]

let myFlags: [[String:Any]] = [
    [kFlag: "--help", kFlagShort: "-h", kArgumentCount: 0],
    [kFlag: "--list", kFlagShort: "-l", kArgumentCount: 0],
    [kFlag: "--append", kFlagShort: "-a", kArgumentCount: 1]
]

let parser = ArgumentParser(flagsToParse: myFlags, inputToParse: userInput2)
println(parser.parsedInput)




