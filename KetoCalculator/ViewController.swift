
//
//  ViewController.swift
//  KetoCalculator
//
//  Created by toaster on 2021/10/30.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet private weak var defaultTargetLabel: UILabel!
    @IBOutlet private weak var ketoEquationSelgmentedControl: UISegmentedControl!
    @IBOutlet private weak var calculatedResultView: UIView!
    @IBOutlet private weak var calculatedResultLabel: UILabel!
    
    @IBOutlet private weak var resultLabelView: UIView!
    @IBOutlet private weak var informationView: UIView!
    
    @IBOutlet private weak var inputProteinTextField: UITextField!
    @IBOutlet private weak var inputFatTextField: UITextField!
    @IBOutlet private weak var inputCarbohydrateTextField: UITextField!
    @IBOutlet private weak var inputSugarTextField: UITextField!
    
    @IBOutlet private weak var StackView: UIStackView!
    @IBOutlet private weak var proteinStackView: UIStackView!
    @IBOutlet private weak var fatStackView: UIStackView!
    @IBOutlet private weak var CarbohydrateStackView: UIStackView!
    @IBOutlet private weak var topStack: NSLayoutConstraint!
    @IBOutlet private weak var CalcButtonBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet private weak var inputFieldView: UIView!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var calculateButton: UIButton!
    
    private var inputTextFields:[UITextField] {
        [inputProteinTextField,
         inputFatTextField,
         inputCarbohydrateTextField,
         inputSugarTextField]
    }
    
    private var defaultTarget:Double = 3.0
    
    private var calculatedResult:Double?
    private var protein:Double?
    private var fat:Double?
    private var carbohydrate:Double?
    private var sugar:Double?
    private var lipidRequirement:Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculatedResultLabel.text = nil
        defaultTargetLabel.text = "現在の目標値：\(defaultTarget)"
        configure()
        enableTextField()
        enableInfoButton()
        
        ketoEquationSelgmentedControl
            .addTarget(self,
                       action: #selector(segmentedControlValueChanged),
                       for: .valueChanged)
        
        inputTextFields.forEach {
            $0.addTarget(self,
                          action: #selector(textFieldEditingDidEnd),
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
        
        [inputFieldView,
         infoButton,
         resultLabelView,
         informationView].forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.shadowOffset = CGSize(width: 0, height: 0)
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
        
        if inputFieldView.frame.height < 220 {
            StackView.setCustomSpacing(5, after: proteinStackView)
            StackView.setCustomSpacing(5, after: fatStackView)
            StackView.setCustomSpacing(5, after: CarbohydrateStackView)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let infomationVC = segue.destination as? InfomationViewController else { return }
        infomationVC.lipidRequirement(completion: { [weak self] () -> Double in

            let lipidRequirement:Double
            guard let defaultTarget = self?.defaultTarget,
                  let calculatedResult = self?.calculatedResult,
                  let protein = self?.protein else {
                return 0
            }

            switch self?.ketoEquationSelgmentedControl.selectedSegmentIndex {
            case 0: guard let carbohydrate = self?.carbohydrate else { return 0}
                    lipidRequirement = (defaultTarget - calculatedResult) * (protein + carbohydrate)
            case 1: guard let carbohydrate = self?.carbohydrate else { return 0}
                    lipidRequirement = (0.46 * protein - defaultTarget * (carbohydrate + 0.58 * protein)) / ( 0.1 * defaultTarget - 0.9)
            case 2: guard let sugar = self?.sugar else { return 0 }
                    lipidRequirement =  (0.46 * protein - defaultTarget * (sugar + 0.58 * protein)) / ( 0.1 * defaultTarget - 0.9)
            default:
                return 0
            }

            self?.lipidRequirement = lipidRequirement
            return lipidRequirement
        })
    }
    
    @objc private func segmentedControlValueChanged() {
        calculatedResult = nil
        calculatedResultLabel.text = nil
        
        enableCalculateButton()
        enableInfoButton()
        enableTextField()
    }
    
    @objc private func textFieldEditingDidEnd() {
        enableCalculateButton()
    }
    
    @IBAction private func exit(segue: UIStoryboardSegue) {
        
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
        
        switch ketoEquationSelgmentedControl.selectedSegmentIndex {
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
            enableInfoButton()
            return
        }
        
        calculatedResultLabel.text = String(round(calculatedResult * 10) / 10)
        enableInfoButton()
    }
}

extension ViewController {
    
    private func enableCalculateButton() {
        calculateButton.isEnabled = isValid()
                
        if calculateButton.isEnabled {
            calculateButton.layer.opacity = 1
        } else {
            calculateButton.layer.opacity = 0.5
        }
    }
    
    private func enableInfoButton() {
        
        guard calculatedResult != nil else {
            infoButton.isEnabled = false
            infoButton.layer.opacity = 0.5
            return
        }
        
        infoButton.isEnabled = true
        infoButton.layer.opacity = 1
    }
    
    private func enableTextField() {
        
        if ketoEquationSelgmentedControl.selectedSegmentIndex == 0 ||
           ketoEquationSelgmentedControl.selectedSegmentIndex == 1 {
            
            inputCarbohydrateTextField.isEnabled = true
            inputCarbohydrateTextField.layer.opacity = 1
            
            inputSugarTextField.isEnabled = false
            inputSugarTextField.layer.opacity = 0.5

        } else if ketoEquationSelgmentedControl.selectedSegmentIndex == 2 {
            
            inputCarbohydrateTextField.isEnabled = false
            inputCarbohydrateTextField.layer.opacity = 0.5
            
            inputSugarTextField.isEnabled = true
            inputSugarTextField.layer.opacity = 1
        }
    }

    private func isValid() -> Bool {
        
        var isValid:Bool
        
        if ketoEquationSelgmentedControl.selectedSegmentIndex == 0 ||
           ketoEquationSelgmentedControl.selectedSegmentIndex == 1 {
            
            isValid = [inputProteinTextField.text!,
                       inputFatTextField.text!,
                       inputCarbohydrateTextField.text!].allSatisfy {
                        !$0
                            .trimmingCharacters(in:.whitespacesAndNewlines)
                            .isEmpty
                        
                        if Double($0) != nil {
                            return true
                        } else {
                            return false
                        }
                       }
            
            return isValid
            
        } else if ketoEquationSelgmentedControl.selectedSegmentIndex == 2 {
            
            isValid = [inputProteinTextField.text!,
                       inputFatTextField.text!,
                       inputSugarTextField.text!].allSatisfy {
                        !$0
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty
                        
                        if Double($0) != nil {
                            return true
                        } else {
                            return false
                        }
                       }
            
            return isValid
            
        } else {
            isValid = false
            return isValid
        }
        
    }
}
