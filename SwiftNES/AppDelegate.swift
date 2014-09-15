//
//  AppDelegate.swift
//  SwiftNES
//
//  Created by Breckin Loggins on 9/13/14.
//  Copyright (c) 2014 Breckin Loggins. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!
  @IBOutlet var textView: NSTextView!
  
  var nesfile : Nesfile?
  
  func applicationDidFinishLaunching(aNotification: NSNotification?) {
    Logger.callback = loggingCallback
    
    Logger.info("SwiftNES initialized")
  }

  func applicationWillTerminate(aNotification: NSNotification?) {
    // Insert code here to tear down your application
  }
  
  func openDocument(sender : AnyObject) {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false
    openPanel.allowedFileTypes = ["nes"]
    openPanel.runModal()
    
    let chosenFile = openPanel.URL
    if (chosenFile != nil) {
      self.nesfile = Nesfile.loadFromURL(chosenFile)
      if self.nesfile == nil {
        Logger.fail("Selected nes file could not be loaded because it was corrupt or invalid")
      } else {
        Logger.info("Nes file loaded successfully")
      }
    }
  }
  
  private func loggingCallback(logType : LogType, message : String) {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      let message = Logger.formattedMessage(logType, message: message)
      self.textView.textStorage.appendAttributedString(NSAttributedString(string: message))
      self.textView.scrollRangeToVisible(NSMakeRange(countElements(self.textView.string), 0))
    })
  }
}

