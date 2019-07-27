//
//  OpenNumpadKeyboard.swift
//  KeyboardKitExampleKeyboard
//
//  Created by Aleksander Evtuhov on 27/07/2019.
//  Copyright © 2019 Daniel Saidi. All rights reserved.
//

import UIKit
import KeyboardKit

class OpenNumpadKeyboard: OpenKeyboardType {
    
    init(){}
    
    func actions(
        in viewController: OpenKeyboardViewController
        ) -> KeyboardActionRows {
        return KeyboardActionRows
            .from(characters)
            .addingSideActions()
        
    }
    
    let characters: [[String]] = [
        ["1", "2", "3", ],
         ["4", "5", "6", ],
          ["7", "8", "9", ],
           ["0"],
        
    ]
    
    var switchAction: KeyboardAction {
        return .switchToKeyboard(.numeric)
    }
}

private extension Sequence where Iterator.Element == KeyboardActionRow {
    func addingSideActions() -> [Iterator.Element] {
        var result = map { $0 }
        result[3].insert(.switchKeyboard, at: 0)
        result[3].append(.backspace)
        return result
    }
}

extension OpenNumpadKeyboard: OpenKeyboardTypeDelegate {
    
    func button(
        for action: KeyboardAction,
        in viewController: KeyboardInputViewController,
        distribution: UIStackView.Distribution
        ) -> UIView {
        if case let .customSpacing(width) = action {
            return KeyboardSpacerView(width: CGFloat(width))
        }
        let view: DemoButton = DemoButton.fromNib(owner: viewController)
        if .backspace == action {
            view.setup(with: action, in: viewController, distribution: distribution, borderless: true)
        } else {
            view.setup(with: action, in: viewController, distribution: distribution)
        }
        
        
        //6s
        var width: CGFloat = 1.0
        if viewController.view.frame.width == 375 {
            let ds: CGFloat = 5
            switch view.action {
            case .backspace: width = ds
            case .switchKeyboard: width = ds
            case .switchToKeyboard(_): width = ds
            default: width = ds
            }
        } else {
            let ds: CGFloat = 5
            switch view.action {
            case .none: width = ds
            case .shift, .shiftDown, .backspace: width = ds
            case .space: width = ds * 5
            case .switchKeyboard: width = ds * 1.5
            case .switchToKeyboard(_): width = ds * 1.5
            case .newLine: width = ds * 3
            case .custom(name: "en"): width = ds * 1.2
            default: width = ds
            }
        }
        view.width = width
        return view
    }
}
