//
//  AppDelegate.swift
//  NewMan
//
//  Created by Weykon Kong on 2022/12/15.
//
import Cocoa
import HotKey
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var Menu: NSMenu!
    
    var eventMonitor: EventMonitor?
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let toggleHotKey = HotKey(key: .space, modifiers: [.option])
    var refreshHotKey : HotKey?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
      
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named:"StatusIcon")
            button.action = #selector(togglePopover(_:))
            // 点击事件
            button.action = #selector(mouseClickHandler)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        popover.contentViewController = PopoverViewController.freshController()
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(event!)
            }
        }
        
        // 修复按钮单击事件无效问题
        Menu.delegate = self;
        
        toggleHotKey.keyDownHandler = {
            self.togglePopover(self.popover)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    let popover = NSPopover()
    
    // 控制Popover状态
    @objc func togglePopover(_ sender: AnyObject) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    // 设置应用内快捷键，启用
    func onListenRefreshHotkey () {
        refreshHotKey = HotKey(key: .r, modifiers: [.command])
        refreshHotKey?.keyDownHandler = {
            let popoverViewController = self.popover.contentViewController as! PopoverViewController
            popoverViewController.WebView?.reload()
        }
    }
    func unregisterRefreshHotkey(){
        refreshHotKey?.keyDownHandler = nil
        refreshHotKey?.keyUpHandler = nil
        refreshHotKey = nil
    }
    // 显示Popover
    @objc func showPopover(_ sender: AnyObject) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            onListenRefreshHotkey()
        }
        eventMonitor?.start()
    }
    // 隐藏Popover
    @objc func closePopover(_ sender: AnyObject) {
        popover.performClose(sender)
        unregisterRefreshHotkey()
        eventMonitor?.stop()
    }
    // 接管togglePopover
    @objc func mouseClickHandler() {
        if let event = NSApp.currentEvent {
            switch event.type {
            case .leftMouseUp:
                togglePopover(popover)
            default:
                statusItem.menu = Menu
                statusItem.button?.performClick(nil)
            }
        }
    }

    @IBAction func Quit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func Refresh(_ sender: Any) {
        let popoverViewController = popover.contentViewController as! PopoverViewController
        popoverViewController.WebView?.reload()
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        // 在这里检查是否应该启用菜单栏按钮
        return true
    }
    
}

extension AppDelegate: NSMenuDelegate {
    
    // 为了保证按钮的单击事件设置有效，menu要去除
    func menuDidClose(_ menu: NSMenu) {
        self.statusItem.menu = nil
    }
    
    func validateUserInterfaceItem(_ item:NSValidatedUserInterfaceItem) -> Bool {
        if item.action == #selector(doOpen){
            return true
        }
        return false
    }
    
    @objc func doOpen(){
        
    }
}
