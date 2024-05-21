//
//  MainViewController.swift
//  Metal-UIKit-Study
//
//  Created by 이전희 on 5/21/24.
//

import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        addSubviews()
        makeConstraints()
    }
    
    private func configure() {
        self.view.backgroundColor = .white
        self.addChild(mtkViewController)
        
        let metalAdder = MetalAdder()
        metalAdder.prepareData(firstArray: [1,2,3],
                               secondArray: [4,5,6],
                               arrayLength: 3)
        metalAdder.sendAddCommand()
    }
    
    private func addSubviews() {

    }
    
    private func makeConstraints() {

    }
}
