//
//  Memory.swift
//  SwiftNES
//
//  Created by Breckin Loggins on 9/14/14.
//  Copyright (c) 2014 Breckin Loggins. All rights reserved.
//

import Foundation

class Memory {
  let capacity : Int
  private var bytes : [UInt8] // Obviously we don't support mirroring or anything else fancy yet
  
  init(capacity: Int) {
    self.capacity = capacity
    self.bytes = [UInt8](count: capacity, repeatedValue: 0)
    
    Logger.info("Initialized NES memory with capacity of \(capacity) bytes")
  }
  
  subscript(address : Int) -> UInt8 {
    get {
      if address < 0 || address >= self.capacity {
        Logger.fail("Memory fault attempting to access memory at address \(address)")
        // TODO: Raise the memory fault as an error
        return 0
      }
      
      return self.bytes[address]
    }
    
    set(newValue) {
      if address < 0 || address >= self.capacity {
        Logger.fail("Memory fault attempting to set memory at address \(address)")
        // TODO: Raise the memory fault as an error
        return
      }
      
      self.bytes[address] = newValue
    }
  }
  
  func fill(startIndex : Int, data : [UInt8]) -> Bool {
    if startIndex + data.count > self.capacity {
      Logger.fail("Attempt to fill \(data.count) bytes of memory past capacity (of \(self.capacity) bytes)")
      return false
    }
    
    self.bytes[startIndex..<startIndex+data.count] = data[0..<data.count]
    
    return true
  }
}