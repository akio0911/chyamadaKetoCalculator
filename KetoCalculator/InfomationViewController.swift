//
//  InfomationViewController.swift
//  KetoCalculator
//
//  Created by toaster on 2021/11/16.
//

import UIKit

final class InfomationViewController: UIViewController {
    
    private var lipidRequirement:Double?

    @IBOutlet private weak var exitButton: UIButton!
    @IBOutlet private weak var lipidRequirementView: UIView!
    @IBOutlet private weak var lipidRequirementLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        display(lipidRequirement: lipidRequirement)
    }
    
    private func configure() {
        [lipidRequirementView,
         exitButton].forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0?.layer.shadowColor = UIColor.black.cgColor
            $0?.layer.shadowOpacity = 0.3
        }
    }
    
    private func display(lipidRequirement:Double?) {
        guard let lipidRequirement = lipidRequirement else { return }
        if lipidRequirement < 100 {
            lipidRequirementLabel.text = String(format:"%.f",lipidRequirement) + "g"
        } else {
            lipidRequirementLabel.text = "100g以上"
        }
    }
        
    func lipidRequirement(completion: @escaping () -> Double?){
        lipidRequirement = completion()
    }
    
}
