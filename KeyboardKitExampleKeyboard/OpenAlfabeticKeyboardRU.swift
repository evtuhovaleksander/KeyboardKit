//
//  OpenAlfabeticKeyboardRU.swift
//  KeyboardKitExampleKeyboard
//
//  Created by Aleksander Evtuhov on 27/07/2019.
//  Copyright © 2019 Daniel Saidi. All rights reserved.
//

import UIKit
import KeyboardKit

class OpenAlfabeticKeyboardRU: OpenKeyboardType {
    
    init(){}
    
    func actions(
        uppercased: Bool,
        needsInputModeSwitchKey: Bool,
        in viewController: OpenKeyboardViewController
        ) -> KeyboardActionRows {
        return KeyboardActionRows
            .from(characters(uppercased: uppercased))
            .addingSideActions(uppercased: uppercased)
            .appending(bottomActions(leftmost: switchAction, needsInputModeSwitchKey: needsInputModeSwitchKey, for: viewController))
    }
    
    let characters: [[String]] = [
        ["й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х"],
        ["ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э"],
        ["я", "ч", "с", "м", "и", "т", "ь", "б", "ю"]
    ]
    
    func characters(uppercased: Bool) -> [[String]] {
        return uppercased ? characters.uppercased() : characters
    }
    
     var switchAction: KeyboardAction {
        return .switchToKeyboard(.numeric)
    }

    func bottomActions(
        leftmost: KeyboardAction,
        needsInputModeSwitchKey: Bool,
        for viewController: OpenKeyboardViewController
    ) -> KeyboardActionRow {
        let actions = needsInputModeSwitchKey
            ? [leftmost, .switchKeyboard, .custom(name: "en"), .space, .newLine]
            : [leftmost, .custom(name: "en") ,.space, .newLine]
        return actions
    }
}

private extension Sequence where Iterator.Element == KeyboardActionRow {
    func addingSideActions(uppercased: Bool) -> [Iterator.Element] {
        var result = map { $0 }
        result[2].insert(uppercased ? .shiftDown : .shift, at: 0)
        result[2].append(.backspace)
        return result
    }
}

extension OpenAlfabeticKeyboardRU: OpenKeyboardTypeDelegate {
    
    func button(
        for action: KeyboardAction,
        in viewController: KeyboardInputViewController,
        distribution: UIStackView.Distribution
    ) -> UIView {
        if action == .none { return KeyboardSpacerView(width: 10) }
        let view = DemoButton.fromNib(owner: viewController)
        view.setup(with: action, in: viewController, distribution: distribution)
        
        //6s
        var width: CGFloat = 1.0
        if viewController.view.frame.width == 375 {
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
