//
//  Logger.swift
//  SwiftNES
//
//  Created by Breckin Loggins on 9/13/14.
//  Copyright (c) 2014 Breckin Loggins. All rights reserved.
//

import Foundation

enum LogType : String, Printable{
  case Info = "INFO"
  case Warning = "WARNING"
  case Error = "ERROR"
  
  var description : String {
    get {
      return self.toRaw()
    }
  }
}

struct Logger {
  static var callback : ((LogType, String) -> ())?
  
  static func info(message: String) { log(.Info, message: message) }
  static func warn(message: String) { log(.Warning, message: message) }
  static func fail(message: String) { log(.Error, message: message) }
  
  static func formattedMessage(logType : LogType, message : NSString) -> String {
    return "[\(logType)] \(message)\n"
  }
  
  private static func log(logType : LogType, message : NSString) {
    if let cb = self.callback {
      cb(logType, message)
    } else {
      println(formattedMessage(logType, message: message))
    }
  }
}
