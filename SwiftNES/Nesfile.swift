//
//  Nesfile.swift
//  SwiftNES
//
//  Created by Breckin Loggins on 9/13/14.
//  Copyright (c) 2014 Breckin Loggins. All rights reserved.
//

import Foundation

// iNES ROM format: http://wiki.nesdev.com/w/index.php/INES
class Nesfile {
  
  class func loadFromURL(url: NSURL) -> Nesfile? {
    let nesfile = Nesfile(url: url)
    return nesfile.isValid ? nesfile : nil
  }
  
  let url : NSURL
  
  var isValid : Bool {
    get {
      return self.header != nil
    }
  }
  
  private let header : Header?
  
  private init(url : NSURL) {
    self.url = url
    let data = NSData(contentsOfFile: self.url.path!)
    Logger.info("Loaded \(self.url) (\(data.length) bytes)")
    
    //self.header = readHeader()
    
  }
  
  private func readHeader() -> Header? {
    return Header(magic: "", prg_size: 0, chr_size: 0, flags6: 0, flags7: 0, prg_ram_size: 0, flags9: 0)
  }
}

// MARK: iNES header flags
extension Nesfile {
  private struct NESFlags6 {
    static let MirroringMask    = 0b00001001
    static let BatteryMask      = 0b00000010
    static let TrainerMask      = 0b00000100
    static let LowerMapperMask  = 0b11110000
  }
  
  private struct NESFlags7 {
    static let VSUnisystemMask  = 0b00000001
    static let Playchoice10Mask = 0b00000010
    static let NES20Mask        = 0b00001100
    static let UpperMapperMask  = 0b11110000
  }
  
  private struct NESFlags9 {
    static let TVSystemMask     = 0b00000001
    static let ReservedMask     = 0b11111110
  }
}

// MARK: iNES header
extension Nesfile {
  private struct Header {
    let magic : String          // Should be "NES" + 0x1A
    let prg_size: UInt8         // PRG ROM size in 16KB units
    let chr_size: UInt8         // CHR ROM size in 8KB units (or 0)
    let flags6: UInt8           // See NESFlags6
    let flags7: UInt8           // See NESFlags7
    let prg_ram_size: UInt8     // PRG RAM size in 8KB units (or 0 for 8KB)
    let flags9: UInt8           // See NESFlags9
  }
}