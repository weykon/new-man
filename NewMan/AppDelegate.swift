//
//  AppDelegate.swift
//  NewMan
//
//  Created by Weykon Kong on 2022/12/15.
//
import Cocoa
import HotKey
import Darwin

@main
class AppDelegate: NSObject, NSApplicationDelegate  {
    @IBOutlet weak var Menu: NSMenu!

    @IBOutlet weak var PortTextField: NSTextField!
    
    @IBAction func update_proxy(_ sender: NSButton) {
        print("update_proxy",PortTextField.stringValue)
        let port = PortTextField.stringValue
        let names = ["https_proxy","http_proxy","all_proxy"]
        let value = [
            "http://127.0.0.1:"+port,
            "http://127.0.0.1:"+port,
            "socks5://127.0.0.1:"+port
        ]
        let overwrite: Int32 = 1
        
        for (index,name) in names.enumerated() {
            setenv(name, value[index], overwrite)
        }
    }
    
    var eventMonitor: EventMonitor?
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let toggleHotKey = HotKey(key: .space, modifiers: [.option])
    var refreshHotKey : HotKey?
    var escHotKey: HotKey?

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
    func onListenOpeningHotkey () {
        refreshHotKey = HotKey(key: .r, modifiers: [.command])
        refreshHotKey?.keyDownHandler = {
            let popoverViewController = self.popover.contentViewController as! PopoverViewController
            popoverViewController.WebView?.reload()
        }
        escHotKey = HotKey(key: .escape,modifiers:[])
        escHotKey?.keyDownHandler = {
            self.closePopover(self.popover)
        }
    }
    func unregisterClosingHotkey(){
        refreshHotKey?.keyDownHandler = nil
        refreshHotKey?.keyUpHandler = nil
        refreshHotKey = nil
        escHotKey?.keyDownHandler = nil
        escHotKey?.keyUpHandler = nil
        escHotKey = nil
    }
    // 显示Popover
    @objc func showPopover(_ sender: AnyObject) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            onListenOpeningHotkey()
            // 降低显示层级 (en: lower view layout)
            popover.contentViewController?.view.window?.level=NSWindow.Level.submenu;
        }
        eventMonitor?.start()
    }
    
    // 隐藏Popover  (en: hide popover)
    @objc func closePopover(_ sender: AnyObject) {
        popover.performClose(sender)
        unregisterClosingHotkey()
        eventMonitor?.stop()
    }
    // 接管togglePopover (en: handle toggle popover)
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

extension AppDelegate: NSMenuDelegate, NSTextFieldDelegate {
    
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
    
     func controlTextDidEndEditing(_ obj: Notification) {
         print("did end");
    }
    
}
