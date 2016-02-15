//
//  UIColor+initWithHexString.swift
//  Emag
//
//  Created by Morgan Wilde on 13/02/2016.
//  Copyright © 2016 Morgan Wilde. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  // Initialiser for strings of format '#_RED_GREEN_BLUE_'
  convenience init(hex: String) {
    let redRange    = Range<String.Index>(start: hex.startIndex.advancedBy(1), end: hex.startIndex.advancedBy(3))
    let greenRange  = Range<String.Index>(start: hex.startIndex.advancedBy(3), end: hex.startIndex.advancedBy(5))
    let blueRange   = Range<String.Index>(start: hex.startIndex.advancedBy(5), end: hex.startIndex.advancedBy(7))
    
    var red     : UInt32 = 0
    var green   : UInt32 = 0
    var blue    : UInt32 = 0
    
    NSScanner(string: hex.substringWithRange(redRange)).scanHexInt(&red)
    NSScanner(string: hex.substringWithRange(greenRange)).scanHexInt(&green)
    NSScanner(string: hex.substringWithRange(blueRange)).scanHexInt(&blue)
    
    self.init(
      red: CGFloat(red) / 255,
      green: CGFloat(green) / 255,
      blue: CGFloat(blue) / 255,
      alpha: 1
    )
  }
}