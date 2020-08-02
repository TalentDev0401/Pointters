//
//  CreditCardInfoTextField.swift
//  ThinCreditCard
//
//  Created by Serg Tsarikovskiy on 05.12.17.
//  Copyright © 2017 Serg Tsarikovskiy. All rights reserved.
//

import UIKit

protocol CreditCardInfoTextFieldDelegate: class {
    func didEdit(textField: CreditCardInfoTextField, with text: String)
    func didResignFirstResponder(textField: CreditCardInfoTextField)
    func didBecomeFirstResponder(textField: CreditCardInfoTextField)
}

final class CreditCardInfoTextField: UITextField {
    
    enum Info {
        case number
        case expiryDate
        case cvc
        
        var placeholder: String {
            switch self {
            case .number:
                return "0000 0000 0000 0000 000"
            case .expiryDate:
                return "MM/YY"
            case .cvc:
                return "CVV"
            }
        }
        
        var cropCharactersCount: Int {
            switch self {
            case .number:
                return 4
            default:
                return 0
            }
        }
    }

    // MARK: - Constants
    struct C {
        static let delay = 0.1
        static let duration = 0.3
        static let animationKey = "kCATransitionFade"
    }

    // MARK: - Properties
    private var validator: CreditCardTextValidatorProtocol?
    private var formatter: CreditCardTextFormatterProtocol?
    public weak var infoDelegate: CreditCardInfoTextFieldDelegate?
    var info: Info = .number
    
    func configure(info: Info,
                   validator: CreditCardTextValidatorProtocol,
                   formatter: CreditCardTextFormatterProtocol? = nil) {
        self.delegate = self
        self.info = info
        updatePlaceholder()
        self.validator = validator
        self.formatter = formatter
        
        if let _ = formatter {
            addTarget(self, action: #selector(formatText(textField:)), for: .editingChanged)
        }
    }

    @objc func formatText(textField: UITextField) {
        textField.text = formatter?.format(text: textField.text!)
    }
}

// MARK: - UITextFieldDelegate
extension CreditCardInfoTextField: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        //resetText()
        infoDelegate?.didBecomeFirstResponder(textField: self)
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let textFieldText = text, let validator = validator else { return true }
        
        let newLength = textFieldText.count + string.count - range.length
        let continueTyping = newLength <= validator.maxLength

        guard continueTyping else { return continueTyping }
        
        textColor = .black
        let newString = range.length == 0 ? textFieldText + string : String(textFieldText.dropLast())
        infoDelegate?.didEdit(textField: self, with: newString)

        guard newLength == validator.maxLength else { return continueTyping }
        guard validator.validate(text: newString) else {
            return continueTyping
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + C.delay, execute: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.resignFirstResponder()
            strongSelf.infoDelegate?.didResignFirstResponder(textField: strongSelf)
        })
        
        return continueTyping
   }
}

// MARK: - Private Methods
private extension CreditCardInfoTextField {
    
    func resetText() {
        text = ""
    }
    
    func updatePlaceholder() {
        switch info {
        case .number:
            animate(placeholder: info.placeholder)
        case .expiryDate:
            animate(placeholder: info.placeholder)
        case .cvc:
            animate(placeholder: info.placeholder)
        default:
            break
        }
    }
}

// MARK: - Animations
private extension CreditCardInfoTextField {
    
    func animate(placeholder: String) {
        transition { [weak self] in
            self?.placeholder = placeholder
        }
    }
    
    func animate(text: String) {
        transition { [weak self] in
            self?.text = text
        }
    }
    
    func transition(animations: @escaping () -> Void) {
        UIView.transition(with: self,
                          duration: C.duration,
                          options: .transitionCrossDissolve,
                          animations: animations)
    }
}
