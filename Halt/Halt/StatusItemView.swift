//
//  StatusItem.swift
//  Babble
//
//  Created by Chris Calo on 12/3/14.
//  Copyright (c) 2014 Vulcan Creative, LLC. All rights reserved.
//

import Cocoa
import Foundation

@IBDesignable
class StatusItemView: NSView
{
  @IBInspectable var backgroundColor: NSColor = NSColor.clearColor() { didSet{ needsDisplay = true } }
  
  @IBInspectable var highlightBackgroundColor: NSColor = NSColor(calibratedHue: 0.619, saturation: 0.9, brightness: 0.98, alpha: 1.0) { didSet{ needsDisplay = true } }
  
  @IBInspectable var backgroundImage: NSImage? = nil { didSet{ needsDisplay = true } }
  
  @IBInspectable var backgroundHighlightImage: NSImage? = nil { didSet{ needsDisplay = true } }
  
  @IBInspectable var backgroundImageSize: NSSize = NSMakeSize(0, 0) { didSet{ needsDisplay = true } }
  
  @IBInspectable var backgroundHighlightImageSize: NSSize = NSMakeSize(0, 0) { didSet{ needsDisplay = true } }
  
  @IBInspectable var isHighlighted: Bool = false { didSet{ needsDisplay = true } }
  
  var action: Selector?
  var target: AnyObject?
  
  internal var darkModeSet = false
  
  internal func unHighlight()
  {
    if isHighlighted
    {
      isHighlighted = false
      needsDisplay = true
    }
  }
  
  internal func checkDarkMode()
  {
    let beforeYosemite = (Int(floor(Float(NSAppKitVersionNumber))) <= Int(NSAppKitVersionNumber10_9))
    if !beforeYosemite
    {
      let defaultsDictionary = NSUserDefaults.standardUserDefaults().persistentDomainForName(NSGlobalDomain)
      let style: AnyObject? = defaultsDictionary!["AppleInterfaceStyle"]
      darkModeSet = (style != nil && style is String && (style as String).lowercaseString == "dark")
    
      needsDisplay = true
    }
  }
  
  override func mouseDown(event: NSEvent)
  {
    isHighlighted = !isHighlighted
    needsDisplay = true
    
    if action != nil && target != nil { NSApp!.sendAction(action!, to: target!, from: self) }
    else
    {
      exit(EXIT_FAILURE)
    }
  }
    
  override func rightMouseDown(theEvent: NSEvent)
  {
    NSApplication.sharedApplication().terminate(self)
  }
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    
    // Check if currently in dark mode
    checkDarkMode()
    
    // Listen for global notifier(s)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("unHighlight"), name: "NSApplicationDidResignKeyNotification", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("unHighlight"), name: "NSApplicationDidResignMainNotification", object: nil)
  }
  
  override func drawRect(aRect: NSRect)
  {
    super.drawRect(aRect)
    
    var iconWidth: CGFloat = 0.0
    var iconHeight: CGFloat = 0.0
    var iconPosition = NSMakePoint(0.0, 0.0)
    
    if isHighlighted { highlightBackgroundColor.set() }
    else { backgroundColor.set() }
    
    NSRectFill(bounds)
    
    if darkModeSet && backgroundHighlightImage != nil
    {
      iconWidth = backgroundHighlightImageSize.width
      iconHeight = backgroundHighlightImageSize.height
    }
    else if isHighlighted && backgroundHighlightImage != nil
    {
      iconWidth = backgroundHighlightImageSize.width
      iconHeight = backgroundHighlightImageSize.height
    }
    else if backgroundImage != nil
    {
      iconWidth = backgroundImageSize.width
      iconHeight = backgroundImageSize.height
    }
    
    if backgroundImage != nil && backgroundHighlightImage != nil
    {
      iconPosition.x = frame.size.width / 2 - iconWidth / 2
      iconPosition.y = frame.size.height / 2 - iconHeight / 2
      
      let iconFrame: NSRect = NSMakeRect(iconPosition.x, iconPosition.y, iconWidth, iconHeight)
      
      if darkModeSet { backgroundHighlightImage!.drawInRect(iconFrame) }
      else if isHighlighted { backgroundHighlightImage!.drawInRect(iconFrame) }
      else { backgroundImage!.drawInRect(iconFrame) }
    }
  }
  
  deinit { NSNotificationCenter.defaultCenter().removeObserver(self) }
}