//
//  MainViewController.swift
//  Metal-UIKit-Study
//
//  Created by 이전희 on 5/21/24.
//

import UIKit

class MainViewController: UIViewController {
    let mtkViewController: MTKBaseViewController = {
        let mtkVC = MTKBaseViewController()
        return mtkVC
    }()
    
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
        metalAdder.prepareData(firstArray: [1,2,3], secondArray: [4,5,6], arrayLength: 3)
        metalAdder.sendAddCommand()
    }
    
    private func addSubviews() {
        let subviews: [UIView] = [mtkViewController.view]
        subviews.forEach { subview in
            view.addSubview(subview)
        }
    }
    
    private func makeConstraints() {
        mtkViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            mtkViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mtkViewController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mtkViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mtkViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mtkViewController.view.heightAnchor.constraint(equalToConstant: 300)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
