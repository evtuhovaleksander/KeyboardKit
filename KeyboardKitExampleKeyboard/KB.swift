//
//  DemoKeyboardActionHandler.swift
//  KeyboardKitExampleKeyboard
//
//  Created by Daniel Saidi on 2019-04-24.
//  Copyright © 2019 Daniel Saidi. All rights reserved.
//

import KeyboardKit

class KB: UIInputViewController {
    override func loadView() {
        super.loadView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let child = OpenKeyboardViewController()
        child.openInputViewController = self
        view.addSubview(child.view, fill: true)
        addChild(child)
        child.didMove(toParent: parent)
    }
}
