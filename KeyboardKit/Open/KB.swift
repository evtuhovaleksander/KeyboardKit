//
//  DemoKeyboardActionHandler.swift
//  KeyboardKitExampleKeyboard
//
//  Created by Daniel Saidi on 2019-04-24.
//  Copyright © 2019 Daniel Saidi. All rights reserved.
//

import KeyboardKit

open class KB: UIInputViewController {
    override open func loadView() {
        super.loadView()
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        let child = OpenKeyboardViewController()
        child.openInputViewController = self
        child.keyboardActionHandler = OpenKeyboardActionHandler(openKeyboardViewController: child, inputViewController: UIInputViewController(), openKeyboardDelegate: self)
        view.addSubview(child.view, fill: true)
        addChild(child)
        child.didMove(toParent: parent)
    }
}

extension KB: OpenKeyboardDelegate {
    public func handleLongPress(on action: KeyboardAction, view: UIView) {
        
    }
    
    public func handleTap(on action: KeyboardAction, view: UIView) {
        
    }
    
    
}
