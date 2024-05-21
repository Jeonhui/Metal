//
//  MTKViewController.swift
//  Metal-UIKit-Study
//
//  Created by 이전희 on 5/21/24.
//

import UIKit
import MetalKit

class MTKViewController: UIViewController {
    
    var mtkView: MTKView!
    var mtkCommandQueue: MTLCommandQueue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        addSubviews()
        makeConstraints()
        mtkViewConfigure()
    }
    
    private func configure() {
        self.view.backgroundColor = .blue
        mtkView = MTKView(frame: .zero)
        mtkView.device = MTLCreateSystemDefaultDevice() // CPU or GPU device
        mtkView.enableSetNeedsDisplay = true
        mtkView.clearColor = MTLClearColorMake(0.0, 0.5, 0.5, 1.0)
        mtkView.delegate = self
        mtkCommandQueue = mtkView.device?.makeCommandQueue()
    }
    
    private func addSubviews() {
        let subviews: [UIView] = [mtkView]
        subviews.forEach { subview in
            view.addSubview(subview)
        }
    }
    
    private func makeConstraints() {
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            mtkView.topAnchor.constraint(equalTo: view.topAnchor),
            mtkView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mtkView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mtkView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func mtkViewConfigure() {
        
    }
    
    private func render() {
        guard let renderPassDescriptor = mtkView.currentRenderPassDescriptor,
        let commandBuffer = mtkCommandQueue.makeCommandBuffer(),
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        guard let currentDrawable = mtkView.currentDrawable else { return }
        
        commandEncoder.endEncoding()
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
}

extension MTKViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // call when the content size changes
    }
    
    func draw(in view: MTKView) {
        // call when the render function of view is requested
        render()
    }
}
