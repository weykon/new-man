//
//  PopoverViewController.swift
//  NewMan
//
//  Created by Weykon Kong on 2022/12/15.
//

import Cocoa
import WebKit


class PopoverViewController: NSViewController,WKNavigationDelegate {

    @IBOutlet var WebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let url = URL(string: "https://chat.openai.com/chat")!
        
        WebView.load(URLRequest(url: url))
    }
    
    
}

extension PopoverViewController {
    static func freshController() -> PopoverViewController {
        //获取对Main.storyboard的引用
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        // 为PopoverViewController创建一个标识符
        let identifier = NSStoryboard.SceneIdentifier("PopoverViewController")
        // 实例化PopoverViewController并返回
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PopoverViewController else {
            fatalError("Something Wrong with Main.storyboard")
        }
        return viewcontroller
    }
}
