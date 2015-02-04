//
//  AppDelegate.swift
//  Halt
//
//  Created by Chris Calo on 2/4/15.
//  Copyright (c) 2015 Chris Calo. All rights reserved.
//

import Cocoa
import Foundation

var statusItem: NSStatusItem! = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
var statusItemViewController: StatusItemViewController! = StatusItemViewController(nibName: "StatusItemViewController", bundle: nil)
var statusItemInitialToolTip = "Click to disable keyboard; right-click to quit"
var statusItemAltToolTip = "Click to enable keyboard; right-click to quit"

var keyboardDisabled = false
let blacklistedKeyEvents: [NSEventType] = [.KeyDown, .KeyUp, .FlagsChanged]

class CrippledApplication: NSApplication
{
    override func sendEvent(theEvent: NSEvent)
    {
        let type = theEvent.type
        
        if keyboardDisabled && contains(blacklistedKeyEvents, type)
        {
            println("keys disabled")
            return
        }
        
        super.sendEvent(theEvent)
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    var window: NSWindow?
    
    func toggleKeyboardAvailability(sender: StatusItemView)
    {
        if sender.isHighlighted
        {
            NSApp!.activateIgnoringOtherApps(true)
            keyboardDisabled = true
            sender.toolTip = statusItemAltToolTip
        }
        else
        {
            keyboardDisabled = false
            sender.toolTip = statusItemInitialToolTip
        }
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        // Setup the app's status view menu item
        let statusItemView = statusItemViewController.view as StatusItemView
        
        if let menu = NSApp!.mainMenu
        {
            let mainMenuHeight = menu!.menuBarHeight
            let statusItemViewFrame = NSMakeRect(0.0, 0.0, mainMenuHeight, mainMenuHeight)
            
            statusItemView.frame = statusItemViewFrame
        }
        
        statusItemView.target = self
        statusItemView.action = Selector("toggleKeyboardAvailability:")
        
        statusItem.title = ""
        statusItem.view = statusItemView
    }
    
    func applicationWillTerminate(aNotification: NSNotification)
    {
        // Insert code here to tear down your application
    }
}
