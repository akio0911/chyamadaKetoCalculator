//
//  SettingViewController.swift
//  KetoCalculator
//
//  Created by toaster on 2021/11/20.
//

import UIKit

final class SettingViewController: UIViewController {

    @IBOutlet private weak var segmentedControlView: UIView!
    @IBOutlet private weak var targetView: UIView!
    @IBOutlet private weak var rssView: UIView!
    
    @IBOutlet private weak var ketoExpressionSegementedControl: UISegmentedControl!
    @IBOutlet private weak var targetTextField: UITextField!
        
    private var uiView:[UIView] {
        [segmentedControlView,targetView,rssView]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        uiView.forEach {
            $0.layer.cornerRadius = 10
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.3
        }
    }
}
