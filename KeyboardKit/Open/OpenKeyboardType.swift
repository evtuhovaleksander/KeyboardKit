//
//  OpenKeyboardType.swift
//  KeyboardKitExampleKeyboard
//
//  Created by Aleksander Evtuhov on 27/07/2019.
//  Copyright © 2019 Daniel Saidi. All rights reserved.
//

import UIKit
import KeyboardKit

protocol OpenKeyboardType {}
extension OpenKeyboardType {}

protocol OpenKeyboardTypeDelegate {
    func button(
        for action: KeyboardAction,
        in viewController: KeyboardInputViewController,
        distribution: UIStackView.Distribution
        ) -> UIView
}
