//
//  MTKViewController.swift
//  Metal-Cube
//
//  Created by Jeonhui on 5/22/24.
//

import UIKit
import MetalKit

class MTKViewController: UIViewController {
    
    let mtkView: MTKView = MTKView()
    let renderer: MTK3DRenderer
    
    init() {
        self.renderer = .init(self.mtkView)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = mtkView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        addSubviews()
        makeConstraints()
    }
    
    private func configure() {
        
    }
    
    private func addSubviews() {
        
    }
    
    private func makeConstraints() {
        
    }
}


