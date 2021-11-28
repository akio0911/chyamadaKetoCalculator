//
//  ViewController.swift
//  KetoCalculator
//
//  Created by toaster on 2021/10/30.
//

import UIKit

final class CalculationViewController: UIViewController {
    private var defaultTarget: Double = 3.0  // 暫定的な設定
    private var calculatedResult: Double?
    private var protein: Double?
    private var fat: Double?
    private var carbohydrate: Double?
    private var sugar: Double?

    private var inputTextFields: [UITextField] {
        [inputProteinTextField,
         inputFatTextField,
         inputCarbohydrateTextField,
         inputSugarTextField]
    }

    @IBOutlet private weak var defaultTargetLabel: UILabel!
    @IBOutlet private weak var ketoSegmentedControl: UISegmentedControl!

    @IBOutlet private weak var calculatedResultView: UIView!
    @IBOutlet private weak var calculatedResultLabel: UILabel!
    @IBOutlet private weak var resultLabelView: UIView!
    @IBOutlet private weak var informationView: UIView!

    @IBOutlet private weak var inputProteinTextField: UITextField!
    @IBOutlet private weak var inputFatTextField: UITextField!
    @IBOutlet private weak var inputCarbohydrateTextField: UITextField!
    @IBOutlet private weak var inputSugarTextField: UITextField!

    @IBOutlet private weak var textFieldsStackView: UIStackView!
    @IBOutlet private weak var proteinStackView: UIStackView!
    @IBOutlet private weak var fatStackView: UIStackView!
    @IBOutlet private weak var carbohydrateStackView: UIStackView!
    @IBOutlet private weak var inputTextFieldsView: UIView!

    @IBOutlet private weak var calculateButton: UIButton!
    @IBOutlet private weak var infomationButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        calculatedResultLabel.text = nil
        defaultTargetLabel.text = "現在の目標値：\(defaultTarget)"

        configure()
        enableTextField()
        enableInfomationButton()

        ketoSegmentedControl
            .addTarget(self,
                       action: #selector(segmentedControlValueChanged),
                       for: .valueChanged)

        inputTextFields.forEach {
            $0.addTarget(self,
                         action: #selector(textFieldEditingChanged),
                         for: .editingChanged)
        }

        calculateButton
            .addTarget(self,
                       action: #selector(calculate),
                       for: .touchUpInside)
    }

    private func configure() {
        inputTextFields.forEach {
            $0.layer.cornerRadius = 10
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.3
        }

        [inputTextFieldsView,
         infomationButton,
         resultLabelView,
         informationView].forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0?.layer.shadowColor = UIColor.black.cgColor
            $0?.layer.shadowOpacity = 0.3
            $0?.layer.borderColor = UIColor.white.cgColor
            $0?.layer.shadowRadius = 3
         }

        calculateButton.map {
            $0.isEnabled = false
            $0.layer.opacity = 0.5
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.3
            $0.titleLabel?.minimumScaleFactor = 0.1
            $0.layer.cornerRadius = $0.frame.width / 2
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if inputTextFieldsView.frame.height < 220 {
            textFieldsStackView.setCustomSpacing(5, after: proteinStackView)
            textFieldsStackView.setCustomSpacing(5, after: fatStackView)
            textFieldsStackView.setCustomSpacing(5, after: carbohydrateStackView)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let infomationVC = segue.destination as? InfomationViewController else { return }
        infomationVC.lipidRequirement(completion: { [weak self] () -> Double? in
            let lipidRequirement: Double?

            guard let defaultTarget = self?.defaultTarget,
                  let calculatedResult = self?.calculatedResult,
                  let protein = self?.protein,
                  let fat = self?.fat  else {
                lipidRequirement = nil
                return lipidRequirement
            }

            switch self?.ketoSegmentedControl.selectedSegmentIndex {
            case 0:
                guard let carbohydrate = self?.carbohydrate else {
                    lipidRequirement = nil
                    return lipidRequirement
                }
                lipidRequirement = (defaultTarget - calculatedResult) * (protein + carbohydrate) - fat

            case 1:
                guard let carbohydrate = self?.carbohydrate else {
                    lipidRequirement = nil
                    return lipidRequirement
                }
                lipidRequirement =
                    (0.46 * protein - defaultTarget * (carbohydrate + 0.58 * protein)) / ( 0.1 * defaultTarget - 0.9) - fat

            case 2:
                guard let sugar = self?.sugar else {
                    lipidRequirement = nil
                    return lipidRequirement
                }
                lipidRequirement =
                    (0.46 * protein - defaultTarget * (sugar + 0.58 * protein)) / ( 0.1 * defaultTarget - 0.9) - fat

            default:
                lipidRequirement = nil
                return lipidRequirement
            }

            return lipidRequirement
        })
    }

    @IBAction private func exit(segue: UIStoryboardSegue) {
    }

    @objc private func segmentedControlValueChanged() {
        calculatedResult = nil
        calculatedResultLabel.text = nil

        enableCalculateButton()
        enableInfomationButton()
        enableTextField()
    }

    @objc private func textFieldEditingChanged() {
        enableCalculateButton()
    }

    @objc private func calculate() {
        animateView(calculateButton)

        protein = Double(inputProteinTextField.text ?? "")
        fat = Double(inputFatTextField.text ?? "")
        carbohydrate = Double(inputCarbohydrateTextField.text ?? "")
        sugar = Double(inputSugarTextField.text ?? "")

        guard let protein = protein,
              let fat = fat else {
            return
        }

        switch ketoSegmentedControl.selectedSegmentIndex {
        case 0:
            guard let carbohydrate = carbohydrate else { return }
            calculatedResult = Nutrient(protein: protein, fat: fat, carbohydrate: carbohydrate).ketoRatio()
        case 1:
            guard let carbohydrate = carbohydrate else { return }
            calculatedResult = Nutrient(protein: protein, fat: fat, carbohydrate: carbohydrate).ketoIndex()
        case 2:
            guard let sugar = sugar else { return }
            calculatedResult = Nutrient(protein: protein, fat: fat, sugar: sugar).ketoNumber()
        default:
            break
        }

        guard let calculatedResult = calculatedResult else {
            enableInfomationButton()
            return
        }

        calculatedResultLabel.text = String(round(calculatedResult * 10) / 10)
        enableInfomationButton()
    }
}

extension CalculationViewController {
    private func enableCalculateButton() {
        calculateButton.isEnabled = isValid()

        if calculateButton.isEnabled {
            calculateButton.layer.opacity = 1
        } else {
            calculateButton.layer.opacity = 0.5
        }
    }

    private func enableInfomationButton() {
        guard calculatedResult == nil else {
            infomationButton.map {
                $0.isEnabled = true
                $0.layer.opacity = 1
            }
            return
        }

        infomationButton.map {
            $0.isEnabled = false
            $0.layer.opacity = 0.5
        }
    }

    private func enableTextField() {
        if ketoSegmentedControl.selectedSegmentIndex == 0 ||
            ketoSegmentedControl.selectedSegmentIndex == 1 {
            inputCarbohydrateTextField.map {
                $0.isEnabled = true
                $0.layer.opacity = 1
            }

            inputSugarTextField.map {
                $0.isEnabled = false
                $0.layer.opacity = 0.5
            }
        } else if ketoSegmentedControl.selectedSegmentIndex == 2 {
            inputCarbohydrateTextField.map {
                $0.isEnabled = false
                $0.layer.opacity = 0.5
            }

            inputSugarTextField.map {
                $0.isEnabled = true
                $0.layer.opacity = 1
            }
        }
    }

    private func isValid() -> Bool {
        let isValid: Bool

        if ketoSegmentedControl.selectedSegmentIndex == 0 ||
            ketoSegmentedControl.selectedSegmentIndex == 1 {
            isValid = [inputProteinTextField.text,
                       inputFatTextField.text,
                       inputCarbohydrateTextField.text]
                .compactMap { $0 }
                .allSatisfy {
                    _ = !$0
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty

                    if Double($0) == nil {
                        return false
                    } else {
                        return true
                    }
                }

            return isValid
        } else if ketoSegmentedControl.selectedSegmentIndex == 2 {
            isValid = [inputProteinTextField.text,
                       inputFatTextField.text,
                       inputSugarTextField.text]
                .compactMap { $0 }
                .allSatisfy {
                    _ = !$0
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty

                    if Double($0) == nil {
                        return false
                    } else {
                        return true
                    }
                }

            return isValid
        } else {
            isValid = false
            return isValid
        }
    }
}
