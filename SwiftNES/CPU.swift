//
//  CPU.swift
//  SwiftNES
//
//  Created by Breckin Loggins on 9/14/14.
//  Copyright (c) 2014 Breckin Loggins. All rights reserved.
//

// Emulates the Ricoh 6502 variant found in the NES
// http://nesdev.com/6502.txt

import Foundation

class CPU {
  
  // MARK: Registers
  var A   : UInt8     // Accumulator
  var X   : UInt8     // X General Purpose
  var Y   : UInt8     // Y General Purpose
  var SP  : UInt16    // Stack Pointer
  var P   : UInt8     // CPU Status
  var PC  : UInt16    // Program Counter
  
  // MARK: Internal state
  private var cc : Int        // Current clock cycle (PPU master clock cycles 3x CPU)
  private var scanline : Int  // Current scanline
  
  init() {
    self.A = 0
    self.X = 0
    self.Y = 0
    self.SP = 0
    self.P = 0
    self.PC = 0
    
    self.cc = 0
    self.scanline = 0
  }
}