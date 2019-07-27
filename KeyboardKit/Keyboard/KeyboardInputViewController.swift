//
//  KeyboardViewController.swift
//  KeyboardKit
//
//  Created by Dainel Saidi on 2018-03-13.
//  Copyright © 2018 Daniel Saidi. All rights reserved.
//



import UIKit

open class KeyboardInputViewController: UIViewController {
    
    open var openInputViewController: UIInputViewController?
    open var needsInputModeSwitchKey: Bool = true
    // MARK: - View Controller Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(keyboardStackView, fill: true)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillSyncWithTextDocumentProxy()
    }
    
    open func viewWillSyncWithTextDocumentProxy() {}
    
    
    // MARK: - Properties
    
    open var keyboardActionHandler: KeyboardActionHandler?
    
    
    // MARK: - View Properties
    
    public lazy var keyboardStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    
    // MARK: - Public Functions
    
    open func addKeyboardGestures(to button: KeyboardButton) {
        button.removeTapAction()
        button.removeLongPressAction()
        button.removeRepeatingAction()
        if button.action == .switchKeyboard { return addSwitchKeyboardGesture(to: button) }
        addTapGesture(to: button)
        addLongPressGesture(to: button)
        addRepeatingGesture(to: button)
    }
    
    
    // MARK: - UITextInputDelegate
    //bipbipbip
    //    open override func textWillChange(_ textInput: UITextInput?) {
    //        super.textWillChange(textInput)
    //        viewWillSyncWithTextDocumentProxy()
    //    }
}


// MARK: - Private Functions

private extension KeyboardInputViewController {
    
    func addSwitchKeyboardGesture(to button: KeyboardButton) {
        guard let button = button as? UIButton else { return }
        //bip
        //button.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
    }
    
    func addLongPressGesture(to button: KeyboardButton) {
        button.addLongPressAction { [weak self] in
            let handler = self?.keyboardActionHandler
            handler?.handleLongPress(on: button.action, view: button)
        }
    }
    
    func addRepeatingGesture(to button: KeyboardButton) {
        button.addRepeatingAction { [weak self] in
            let handler = self?.keyboardActionHandler
            handler?.handleRepeat(on: button.action, view: button)
        }
    }
    
    func addTapGesture(to button: KeyboardButton) {
        button.addTapAction { [weak self] in
            let handler = self?.keyboardActionHandler
            handler?.handleTap(on: button.action, view: button)
        }
    }
}
