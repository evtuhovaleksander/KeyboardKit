//
//  KeyboardViewController.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2018-03-04.
//  Copyright © 2018 Daniel Saidi. All rights reserved.
//

import UIKit
import KeyboardKit

class OpenKeyboardViewController: KeyboardInputViewController {
    
    var keyboardShiftState = KeyboardShiftState.lowercased
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardActionHandler = OpenKeyboardActionHandler(openKeyboardViewController: self, inputViewController: self)
        autocompleteBugFixTimer = createAutocompleteBugFixTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboard()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setupKeyboard(for: size)
    }
    
    
    // MARK: - Keyboard Functionality
    
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        requestAutocompleteSuggestions()
    }
    
    override func selectionWillChange(_ textInput: UITextInput?) {
        super.selectionWillChange(textInput)
        autocompleteToolbar.reset()
    }
    
    override func selectionDidChange(_ textInput: UITextInput?) {
        super.selectionDidChange(textInput)
        autocompleteToolbar.reset()
    }
    
    
    // MARK: - Properties
    
    var isNumericPad = true {
        didSet {
            guard isNumericPad else { return }
            _keyboardType = .numPad
            setupKeyboard()
        }
    }
    
    let alerter = ToastAlert()
    
    var autocompleteBugFixTimer: AutocompleteBugFixTimer?
    
    var _keyboardType = KeyboardType.numPad {//KeyboardType.alphabetic(ru: true, uppercased: false) {
        didSet {
            setupKeyboard()
        }
    }
    
    var keyboardType: KeyboardType {
        return _keyboardType
    }
    
    func setNewKeyboardAlhabeticType(ru: Bool? = nil, uppercased: Bool? = nil) {
        if case let .alphabetic(oldRu, oldUppercased) = keyboardType {
            var newRu = oldRu
            var newUppercased = oldUppercased
            if let ru = ru {
                newRu = ru
            }
            if let uppercased = uppercased {
                newUppercased = uppercased
            }
            _keyboardType = .alphabetic(ru: newRu, uppercased: newUppercased)
        }
        
    }
    
    func setNewKeyboardType(keyboardType: KeyboardType) {
        _keyboardType = keyboardType
    }
    
    
    var keyboardSwitcherAction: KeyboardAction {
        return needsInputModeSwitchKey ? .switchKeyboard : .switchToKeyboard(.emojis)
    }
    
    
    // MARK: - Autocomplete
    
    private lazy var autocompleteProvider = DemoAutocompleteSuggestionProvider()
    
    private lazy var autocompleteToolbar: AutocompleteToolbar = {
        let proxy = textDocumentProxy
        let toolbar = AutocompleteToolbar(
            buttonCreator: { DemoAutocompleteLabel(word: $0, proxy: proxy) }
        )
        toolbar.update(with: ["foo", "bar", "baz"])
        return toolbar
    }()
    
    private func requestAutocompleteSuggestions() {
        let word = textDocumentProxy.currentWord ?? ""
        autocompleteProvider.provideAutocompleteSuggestions(for: word) { [weak self] in
            switch $0 {
            case .failure(let error): print(error.localizedDescription)
            case .success(let result): self?.autocompleteToolbar.update(with: result)
            }
        }
    }
    
    private func resetAutocompleteSuggestions() {
        autocompleteToolbar.reset()
    }
    
    var openAlfabeticKeyboardRU: OpenAlfabeticKeyboardRU!
    var openAlfabeticKeyboardEN: OpenAlfabeticKeyboardEN!
    var openNumpadKeyboard: OpenNumpadKeyboard!
}


// MARK: - Setup

private extension OpenKeyboardViewController {
    
    func setupKeyboard() {
        setupKeyboard(for: view.bounds.size)
    }
    
    func setupKeyboard(for size: CGSize) {
        DispatchQueue.main.async {
            self.setupKeyboardAsync(for: size)
        }
    }
    
    func setupKeyboardAsync(for size: CGSize) {
        switch keyboardType {
        case let .alphabetic(ru, uppercased): setupAlphabeticKeyboard(ru: ru, uppercased: uppercased)
        case .numeric: setupNumericKeyboard()
        case .numPad: setupNumpadKeyboard()
        case .symbolic: setupSymbolicKeyboard()
        case .emojis: setupEmojiKeyboard(for: size)
        default: return
        }
    }
    
    func setupAlphabeticKeyboard(ru: Bool, uppercased: Bool = false) {
        if ru {
            openAlfabeticKeyboardRU = OpenAlfabeticKeyboardRU()
            let rows = buttonRows(
                for: openAlfabeticKeyboardRU.actions(
                    uppercased: uppercased,
                    needsInputModeSwitchKey: needsInputModeSwitchKey,
                    in: self
                ),
                distribution: .fillProportionally
            )
            keyboardStackView.addArrangedSubviews(rows)
        } else {
            openAlfabeticKeyboardEN = OpenAlfabeticKeyboardEN()
            let rows = buttonRows(
                for: openAlfabeticKeyboardEN.actions(
                    uppercased: uppercased,
                    needsInputModeSwitchKey: needsInputModeSwitchKey,
                    in: self
                ),
                distribution: .fillProportionally
            )
            keyboardStackView.addArrangedSubviews(rows)
        }
    }
    
    func setupNumpadKeyboard() {
        openNumpadKeyboard = OpenNumpadKeyboard()
        let rows = buttonRows(
            for: openNumpadKeyboard.actions(
                in: self
            ),
            distribution: .fillProportionally
        )
        keyboardStackView.addArrangedSubviews(rows)
    }
    
    func setupEmojiKeyboard(for size: CGSize) {}
    func setupNumericKeyboard() {}
    func setupSymbolicKeyboard() {}
}


// MARK: - Private Button Functions

private extension OpenKeyboardViewController  {
    
    func button(for action: KeyboardAction, distribution: UIStackView.Distribution) -> UIView {
        if case let .alphabetic(ru, uppercased) = keyboardType {
            if ru {
                return openAlfabeticKeyboardRU.button(
                    for: action,
                    in: self,
                    distribution: distribution
                )
            } else {
                return openAlfabeticKeyboardEN.button(
                    for: action,
                    in: self,
                    distribution: distribution
                )
            }
            
        } else if case .numPad = keyboardType {
            return openNumpadKeyboard.button(
                for: action,
                in: self,
                distribution: distribution
            )
        }
        else {
            if action == .none { return KeyboardSpacerView(width: 10) }
            let view = DemoButton.fromNib(owner: self)
            view.setup(with: action, in: self, distribution: distribution)
            return view
        }
    }
    
    func buttonRow(
        for actions: KeyboardActionRow,
        distribution: UIStackView.Distribution
        ) -> KeyboardStackViewComponent {
        return KeyboardButtonRow(actions: actions, distribution: distribution) {
            button(for: $0, distribution: distribution)
        }
    }
    
    // константа
    func buttonRows(
        for actionRows: KeyboardActionRows,
        distribution: UIStackView.Distribution
        ) -> [KeyboardStackViewComponent] {
        var rows = actionRows.map {
            buttonRow(for: $0, distribution: distribution)
        }
        rows.insert(autocompleteToolbar, at: 0)
        return rows
    }
}

class OpenKeyboardActionHandler: StandardKeyboardActionHandler {
    
    func switchToAlphabeticKeyboard(_ state: KeyboardShiftState) {
        openKeyboardViewController.keyboardShiftState = state
        openKeyboardViewController.setNewKeyboardAlhabeticType(uppercased: state.isUppercased)
    }
    
    var openKeyboardViewController: OpenKeyboardViewController
    
    public init(
        openKeyboardViewController: OpenKeyboardViewController,
        inputViewController: UIInputViewController
        ) {
        self.openKeyboardViewController = openKeyboardViewController
        super.init(
            inputViewController: inputViewController,
            tapHapticFeedback: .standardTapFeedback,
            longPressHapticFeedback: .standardLongPressFeedback
        )
    }
    
    
    // MARK: - Properties
    // MARK: - Functions
    
    func animateButtonTap(for view: UIView) {
        (view as? KeyboardButton)?.animateStandardTap()
    }
    
    override func handleLongPress(on action: KeyboardAction, view: UIView) {
        animateButtonTap(for: view)
        switch action {
        case .shift: switchToAlphabeticKeyboard(.capsLocked)
        default: super.handleLongPress(on: action, view: view)
        }
    }
    
    override func handleTap(on action: KeyboardAction, view: UIView) {
        animateButtonTap(for: view)
        super.handleTap(on: action, view: view)
        switch action {
        case .shift: switchToAlphabeticKeyboard(.uppercased)
        case .shiftDown: switchToAlphabeticKeyboard(.lowercased)
        case .character:
            if openKeyboardViewController.keyboardShiftState == .uppercased {
                switchToAlphabeticKeyboard(.lowercased)
            }
        case .switchToKeyboard(let type):
            if case let .alphabetic(ru, uppercased) = type {
                openKeyboardViewController.setNewKeyboardAlhabeticType(ru: ru, uppercased: uppercased)
            } else {
                openKeyboardViewController.setNewKeyboardType(keyboardType: type)
            }
        case .custom(name: "ru"): openKeyboardViewController.setNewKeyboardAlhabeticType(ru: true)
        case .custom(name: "en"): openKeyboardViewController.setNewKeyboardAlhabeticType(ru: false)
        default: break
        }
    }
}

//func setupEmojiKeyboard(for size: CGSize) {
//    //        let keyboard = EmojiKeyboard(in: self)
//    //        let isLandscape = size.width > 400
//    //        let rowsPerPage = isLandscape ? 3 : 4
//    //        let buttonsPerRow = isLandscape ? 8 : 6
//    //        let config = KeyboardButtonRowCollectionView.Configuration(rowHeight: 50, rowsPerPage: rowsPerPage, buttonsPerRow: buttonsPerRow)
//    //        let view = KeyboardButtonRowCollectionView(actions: keyboard.actions, configuration: config) { [unowned self] in return self.button(for: $0, distribution: .fillEqually) }
//    //        let bottom = buttonRow(for: keyboard.bottomActions, distribution: .fillProportionally)
//    //        keyboardStackView.addArrangedSubview(view)
//    //        keyboardStackView.addArrangedSubview(bottom)
//}
//
//func setupNumericKeyboard() {
//    //        let keyboard = NumericKeyboard(in: self)
//    //        let rows = buttonRows(for: keyboard.actions, distribution: .fillProportionally)
//    //        keyboardStackView.addArrangedSubviews(rows)
//}
//
//func setupSymbolicKeyboard() {
//    //        let keyboard = SymbolicKeyboard(in: self)
//    //        let rows = buttonRows(for: keyboard.actions, distribution: .fillProportionally)
//    //        keyboardStackView.addArrangedSubviews(rows)
//}

//class KeyboardViewController: KeyboardInputViewController {
//
//    // MARK: - View Controller Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        autocompleteBugFixTimer = createAutocompleteBugFixTimer()
//        keyboardActionHandler = DemoKeyboardActionHandler(inputViewController: self)
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setupKeyboard()
//    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        setupKeyboard(for: size)
//    }
//
//
//    // MARK: - Keyboard Functionality
//
//    override func textDidChange(_ textInput: UITextInput?) {
//        super.textDidChange(textInput)
//        requestAutocompleteSuggestions()
//    }
//
//    override func selectionWillChange(_ textInput: UITextInput?) {
//        super.selectionWillChange(textInput)
//        autocompleteToolbar.reset()
//    }
//
//    override func selectionDidChange(_ textInput: UITextInput?) {
//        super.selectionDidChange(textInput)
//        autocompleteToolbar.reset()
//    }
//
//
//    // MARK: - Properties
//
//    var isNumericPad = true {
//        didSet {
//            guard isNumericPad else { return }
//            _keyboardType = .numPad
//            setupKeyboard()
//        }
//    }
//
//    let alerter = ToastAlert()
//
//    var autocompleteBugFixTimer: AutocompleteBugFixTimer?
//
//    var _keyboardType = KeyboardType.numPad {//KeyboardType.alphabetic(ru: true, uppercased: false) {
//        didSet {
//            setupKeyboard()
//        }
//    }
//
//    var keyboardType: KeyboardType {
//        return _keyboardType
//    }
//
//    func setNewKeyboardAlhabeticType(ru: Bool? = nil, uppercased: Bool? = nil) {
//        if case let .alphabetic(oldRu, oldUppercased) = keyboardType {
//            var newRu = oldRu
//            var newUppercased = oldUppercased
//            if let ru = ru {
//                newRu = ru
//            }
//            if let uppercased = uppercased {
//                newUppercased = uppercased
//            }
//            _keyboardType = .alphabetic(ru: newRu, uppercased: newUppercased)
//        }
//
//    }
//
//    func setNewKeyboardType(keyboardType: KeyboardType) {
//        _keyboardType = keyboardType
//    }
//
//
//    var keyboardSwitcherAction: KeyboardAction {
//        return needsInputModeSwitchKey ? .switchKeyboard : .switchToKeyboard(.emojis)
//    }
//
//
//    // MARK: - Autocomplete
//
//    private lazy var autocompleteProvider = DemoAutocompleteSuggestionProvider()
//
//    private lazy var autocompleteToolbar: AutocompleteToolbar = {
//        let proxy = textDocumentProxy
//        let toolbar = AutocompleteToolbar(
//            buttonCreator: { DemoAutocompleteLabel(word: $0, proxy: proxy) }
//        )
//        toolbar.update(with: ["foo", "bar", "baz"])
//        return toolbar
//    }()
//
//    private func requestAutocompleteSuggestions() {
//        let word = textDocumentProxy.currentWord ?? ""
//        autocompleteProvider.provideAutocompleteSuggestions(for: word) { [weak self] in
//            switch $0 {
//            case .failure(let error): print(error.localizedDescription)
//            case .success(let result): self?.autocompleteToolbar.update(with: result)
//            }
//        }
//    }
//
//    private func resetAutocompleteSuggestions() {
//        autocompleteToolbar.reset()
//    }
//
//    var openAlfabeticKeyboardRU: OpenAlfabeticKeyboardRU!
//    var openAlfabeticKeyboardEN: OpenAlfabeticKeyboardEN!
//    var openNumpadKeyboard: OpenNumpadKeyboard!
//}
//
//
//// MARK: - Setup
//
//private extension KeyboardViewController {
//
//    func setupKeyboard() {
//        setupKeyboard(for: view.bounds.size)
//    }
//
//    func setupKeyboard(for size: CGSize) {
//        DispatchQueue.main.async {
//            self.setupKeyboardAsync(for: size)
//        }
//    }
//
//    func setupKeyboardAsync(for size: CGSize) {
//        switch keyboardType {
//        case let .alphabetic(ru, uppercased): setupAlphabeticKeyboard(ru: ru, uppercased: uppercased)
//        case .numeric: setupNumericKeyboard()
//        case .numPad: setupNumpadKeyboard()
//        case .symbolic: setupSymbolicKeyboard()
//        case .emojis: setupEmojiKeyboard(for: size)
//        default: return
//        }
//    }
//
//    func setupAlphabeticKeyboard(ru: Bool, uppercased: Bool = false) {
//        if ru {
//            openAlfabeticKeyboardRU = OpenAlfabeticKeyboardRU()
//            let rows = buttonRows(
//                for: openAlfabeticKeyboardRU.actions(
//                    uppercased: uppercased,
//                    needsInputModeSwitchKey: needsInputModeSwitchKey,
//                    in: self
//                ),
//                distribution: .fillProportionally
//            )
//            keyboardStackView.addArrangedSubviews(rows)
//        } else {
//            openAlfabeticKeyboardEN = OpenAlfabeticKeyboardEN()
//            let rows = buttonRows(
//                for: openAlfabeticKeyboardEN.actions(
//                    uppercased: uppercased,
//                    needsInputModeSwitchKey: needsInputModeSwitchKey,
//                    in: self
//                ),
//                distribution: .fillProportionally
//            )
//            keyboardStackView.addArrangedSubviews(rows)
//        }
//    }
//
//    func setupNumpadKeyboard() {
//        openNumpadKeyboard = OpenNumpadKeyboard()
//        let rows = buttonRows(
//            for: openNumpadKeyboard.actions(
//                in: self
//            ),
//            distribution: .fillProportionally
//        )
//        keyboardStackView.addArrangedSubviews(rows)
//    }
//
//    func setupEmojiKeyboard(for size: CGSize) {
//        let keyboard = EmojiKeyboard(in: self)
//        let isLandscape = size.width > 400
//        let rowsPerPage = isLandscape ? 3 : 4
//        let buttonsPerRow = isLandscape ? 8 : 6
//        let config = KeyboardButtonRowCollectionView.Configuration(rowHeight: 50, rowsPerPage: rowsPerPage, buttonsPerRow: buttonsPerRow)
//        let view = KeyboardButtonRowCollectionView(actions: keyboard.actions, configuration: config) { [unowned self] in return self.button(for: $0, distribution: .fillEqually) }
//        let bottom = buttonRow(for: keyboard.bottomActions, distribution: .fillProportionally)
//        keyboardStackView.addArrangedSubview(view)
//        keyboardStackView.addArrangedSubview(bottom)
//    }
//
//    func setupNumericKeyboard() {
//        let keyboard = NumericKeyboard(in: self)
//        let rows = buttonRows(for: keyboard.actions, distribution: .fillProportionally)
//        keyboardStackView.addArrangedSubviews(rows)
//    }
//
//    func setupSymbolicKeyboard() {
//        let keyboard = SymbolicKeyboard(in: self)
//        let rows = buttonRows(for: keyboard.actions, distribution: .fillProportionally)
//        keyboardStackView.addArrangedSubviews(rows)
//    }
//}
//
//
//// MARK: - Private Button Functions
//
//private extension KeyboardViewController {
//
//    func button(for action: KeyboardAction, distribution: UIStackView.Distribution) -> UIView {
//        if case let .alphabetic(ru, uppercased) = keyboardType {
//            if ru {
//                return openAlfabeticKeyboardRU.button(
//                    for: action,
//                    in: self,
//                    distribution: distribution
//                )
//            } else {
//                return openAlfabeticKeyboardEN.button(
//                    for: action,
//                    in: self,
//                    distribution: distribution
//                )
//            }
//
//        } else if case .numPad = keyboardType {
//            return openNumpadKeyboard.button(
//                for: action,
//                in: self,
//                distribution: distribution
//            )
//        }
//        else {
//            if action == .none { return KeyboardSpacerView(width: 10) }
//            let view = DemoButton.fromNib(owner: self)
//            view.setup(with: action, in: self, distribution: distribution)
//            return view
//        }
//    }
//
//    func buttonRow(
//        for actions: KeyboardActionRow,
//        distribution: UIStackView.Distribution
//    ) -> KeyboardStackViewComponent {
//        return KeyboardButtonRow(actions: actions, distribution: distribution) {
//            button(for: $0, distribution: distribution)
//        }
//    }
//
//    // константа
//    func buttonRows(
//        for actionRows: KeyboardActionRows,
//        distribution: UIStackView.Distribution
//    ) -> [KeyboardStackViewComponent] {
//        var rows = actionRows.map {
//            buttonRow(for: $0, distribution: distribution)
//        }
//        rows.insert(autocompleteToolbar, at: 0)
//        return rows
//    }
//}
