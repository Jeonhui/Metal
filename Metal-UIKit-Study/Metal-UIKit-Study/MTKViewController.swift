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
    var device: MTLDevice!
    var mtkCommandQueue: MTLCommandQueue!
    
    var pipeLineState: MTLRenderPipelineState!
    
    /*
    (-1, 1)  (0, 1)  (1, 1)
    (-1, 0)  (0, 0)  (1, 0)
    (-1, -1) (0, -1) (1, -1)
     */
    let vertexData: [Float] = [
        0, 1,
        -1, 0,
        1, 0
    ]
    
    let colorData: [Float] = [
        1,0,0,1, // rgba
        0,1,0,1,
        0,0,1,1
    ]
    
    let vertexData2: [Float] = [
        -1, 1,
        0, -1,
        1, 1
    ]
    
    let colorData2: [Float] = [
        1,0,0,1, // rgba
        0,1,0,1,
        0,0,1,1
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        addSubviews()
        makeConstraints()
    }
    
    /*
     GPU stores results in textures when drawing.
     GPU can access textures.
     textures: the memory blocks with image data
     */
    private func configure() {
        self.view.backgroundColor = .blue
        mtkView = MTKView(frame: .zero)
        
        //connect to the gpu
        device = MTLCreateSystemDefaultDevice() // CPU or GPU device
        mtkView.device = device
        
        mtkView.enableSetNeedsDisplay = true // 뷰가 contents의 업데이트가 필요할때만 draw
        
        mtkView.clearColor = MTLClearColorMake(0, 0, 0, 1.0)
        mtkView.delegate = self
        
        //creating the command queue
        mtkCommandQueue = device.makeCommandQueue()
        
        // draw triangle
        let defaultLibrary = device.makeDefaultLibrary()
        let vertexFunction = defaultLibrary?.makeFunction(name: "vertexPassThroughShader")
        let fragmentFunction = defaultLibrary?.makeFunction(name: "fragmentPassThroughShader")
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        pipeLineState = try? device.makeRenderPipelineState(descriptor: descriptor)
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
    
    private func render() {
        // render pass: the sequence of rendering commands for drawing textures.
        // Creating the commandBuffer for the queue
        guard let commandBuffer = mtkCommandQueue.makeCommandBuffer() else { return }
        // screen에 display할 수 있는 textures는 drawable objects에 의해 관리
        guard let currentDrawable = mtkView.currentDrawable else { return }
        guard let renderPassDescriptor = mtkView.currentRenderPassDescriptor else { return }
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        commandEncoder.setRenderPipelineState(pipeLineState)
        
        encodeCommand(to: commandEncoder, vertexData: vertexData, colorData: colorData)
        // encodeCommand(to: commandEncoder, vertexData: vertexData2, colorData: colorData2)
        
        commandEncoder.endEncoding()
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    
    func encodeCommand(to commandEncoder: MTLRenderCommandEncoder,
                       vertexData: [Float],
                       colorData: [Float]) {
        
        let vertexDataSize = vertexData.count * MemoryLayout<Float>.size
        let vertexBuffer = device.makeBuffer(bytes: vertexData,
                                             length: vertexDataSize,
                                             options: [])
        
        let colorDataSize = colorData.count * MemoryLayout<Float>.size
        let colorBuffer = device.makeBuffer(bytes: colorData,
                                            length: colorDataSize,
                                            options: [])
        
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
   
    }
}

extension MTKViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function)
        // call when the content size changes
    }
    
    func draw(in view: MTKView) {
        print(#function)
        // call when the render function of view is requested
        render()
    }
}
