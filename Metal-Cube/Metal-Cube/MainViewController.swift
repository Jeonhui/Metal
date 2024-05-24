//
//  MainViewController.swift
//  Metal-Cube
//
//  Created by Jeonhui on 5/23/24
//


import UIKit

class MainViewController: UIViewController {
    let mtkViewController: MTKViewController = MTKViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        addSubviews()
        makeConstraints()
    }
    
    private func configure() {
        self.view.backgroundColor = .white
        self.addChild(mtkViewController)
        if let uiImage = UIImage(named: "cat") {
            do {
                try mtkViewController
                    .renderer
                    .addTexture(name: "cat", uiImage: uiImage)
            } catch {
                print(error)
            }
        }
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
