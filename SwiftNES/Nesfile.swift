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
  var prgROM : [UInt8]
  
  private init(url : NSURL) {
    self.url = url
    self.prgROM = []
    
    let data = NSData(contentsOfFile: self.url.path!)
    Logger.info("Loaded \(self.url) (\(data.length) bytes)")
    
    if let hdr = readHeader(data) {
      Logger.info("Valid iNES ROM")
      Logger.info("\tPRG ROM 16KB Pages: \(hdr.prg_size)")
      Logger.info("\tCHR ROM 8KB Pages: \(hdr.chr_size)")
      Logger.info("\tPRG RAM 8KB Pages: \(hdr.prg_ram_size)")
      
      if hdr.flags6 & NESFlags6.TrainerMask == NESFlags6.TrainerMask {
        Logger.fail("ROMs with Trainer Sections are not supported")
        return
      }
      
      if hdr.flags6 & NESFlags6.BatteryMask == NESFlags6.BatteryMask {
        Logger.info("\tROM supports a battery")
      }
      
      let mapper = (hdr.flags7 & NESFlags7.UpperMapperMask) | (hdr.flags6 & NESFlags6.LowerMapperMask)
      Logger.info("\tMapper number is \(mapper)")
      if mapper > 0 {
        Logger.fail("Advanced (non-zero) mappers are not currently supported")
        return
      }
      
      let inesVersion = (hdr.flags7 & NESFlags7.NES20Mask) >> 2
      Logger.info("\tiNES Version \(inesVersion+1)")
      if inesVersion > 0 {
        Logger.fail("Unsupported iNES Version")
        return
      }
      
      let mirroring = hdr.flags6 & NESFlags6.MirroringMask
      switch mirroring {
      case 0: Logger.info("\tROM is horizontally mirrored")
      case 1: Logger.info("\tROM is vertically mirrored")
      default:
        Logger.fail("Unsupported mirroring mode \(mirroring)")
        return
      }
      
      let prgROMSize = 0x4000 * Int(hdr.prg_size)
      self.prgROM = [UInt8](count: prgROMSize, repeatedValue: 0)
      data.getBytes(&self.prgROM, range: NSMakeRange(Header.HeaderSize, prgROMSize))
      Logger.info("Loaded PRG ROM (\(prgROMSize) bytes)")
      
      self.header = hdr
    }
    
  }
  
  private func readHeader(data : NSData) -> Header? {
    if data.length < Header.HeaderSize {
      Logger.fail("Supposed iNES file is too small to contain a valid header")
      return nil
    }
    
    let magic = NSString(data: data.subdataWithRange(NSMakeRange(0, 4)), encoding: NSUTF8StringEncoding)
    if magic != "NES\u{1A}" {
      Logger.fail("iNES header magic should be 'NES\u{1A}' but is \(magic)")
      return nil
    }
    
    var hdr = [UInt8](count: Header.HeaderSize - 4, repeatedValue: 0)
    var headerRange = NSMakeRange(4, Header.HeaderSize - 4)
    data.getBytes(&hdr, range: headerRange)
    
    if hdr[8] != 0 || hdr[9] != 0 || hdr[10] != 0 || hdr[11] != 0 {
      Logger.fail("Non-zero data found in iNES header padding; probably not a valid iNES file")
      return nil
    }
    
    return Header(magic: magic,
      prg_size: hdr[0],
      chr_size: hdr[1],
      flags6: hdr[2],
      flags7: hdr[3],
      prg_ram_size: hdr[4] == 0 ? 1 : hdr[4], // Compatibility
      flags9: hdr[5])
  }
}

// MARK: iNES header flags
extension Nesfile {
  private struct NESFlags6 {
    static let MirroringMask : UInt8   = 0b00001001
    static let BatteryMask : UInt8     = 0b00000010
    static let TrainerMask : UInt8     = 0b00000100
    static let LowerMapperMask : UInt8 = 0b11110000
  }
  
  private struct NESFlags7 {
    static let VSUnisystemMask : UInt8  = 0b00000001
    static let Playchoice10Mask : UInt8 = 0b00000010
    static let NES20Mask : UInt8        = 0b00001100
    static let UpperMapperMask : UInt8  = 0b11110000
  }
  
  private struct NESFlags9 {
    static let TVSystemMask : UInt8    = 0b00000001
    static let ReservedMask : UInt8    = 0b11111110
  }
}

// MARK: iNES header
extension Nesfile {
  private struct Header {
    static let HeaderSize = 16
    
    let magic : String          // Should be "NES" + 0x1A
    let prg_size: UInt8         // PRG ROM size in 16KB units
    let chr_size: UInt8         // CHR ROM size in 8KB units (or 0)
    let flags6: UInt8           // See NESFlags6
    let flags7: UInt8           // See NESFlags7
    let prg_ram_size: UInt8     // PRG RAM size in 8KB units (or 0 for 8KB)
    let flags9: UInt8           // See NESFlags9
  }
}