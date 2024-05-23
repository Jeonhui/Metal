//
//  MTKViewController.swift
//  Metal-Cube
//
//  Created by Jeonhui on 5/22/24.
//

import UIKit
import MetalKit

class MTKViewController: UIViewController {
    
    var mtkView: MTKView = MTKView()
    var renderer: Renderer!
    
    override func loadView() {
        self.view = mtkView
        self.renderer = Renderer(mtkView)
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


class Renderer: NSObject {
    weak var view: MTKView!
    
    let device: MTLDevice
    
    let commandQueue: MTLCommandQueue
    
    let library: MTLLibrary
    var vertexFunction: MTLFunction
    var fragmentFunction: MTLFunction
    
    var renderPipelineState: MTLRenderPipelineState
    
    var clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    let vertices: [Vertex] = [
        Vertex(position: simd_float2(-0.5, -0.5), color: simd_float3(1.0, 0.0, 0.0)),
        Vertex(position: simd_float2( 0.5, -0.5), color: simd_float3(0.0, 1.0, 0.0)),
        Vertex(position: simd_float2( 0.0,  0.5), color: simd_float3(0.0, 0.0, 1.0))
    ]
    
    // MARK: - initialize
    init(_ view: MTKView) {
        self.view = view
        
        // 1. Device
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Device not found.")
        }
        self.device = device
        
        // 2. CommandQueue
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Failed to create command queue")
        }
        self.commandQueue = commandQueue
        
        // 3. Shader
        guard let library = device.makeDefaultLibrary(),
              let vertexFunction = library.makeFunction(name: "vertexFunction"),
              let fragmentFunction = library.makeFunction(name: "fragmentFunction") else {
            fatalError("Failed to create Shader")
        }
        self.library = library
        self.vertexFunction = vertexFunction
        self.fragmentFunction = fragmentFunction
        
        // 4. Pipeline state
        let renderPipelineStateDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineStateDescriptor.vertexFunction = vertexFunction
        renderPipelineStateDescriptor.fragmentFunction = fragmentFunction
        renderPipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        guard let renderPipelineState = try? device.makeRenderPipelineState(descriptor: renderPipelineStateDescriptor) else {
            fatalError("Failed to create render pipeline state")
        }
        self.renderPipelineState = renderPipelineState
        
        super.init()
        
        // view settings
        view.delegate = self
        view.device = device
        view.clearColor = clearColor
        view.enableSetNeedsDisplay = true
    }
    
    private func render() {
        // Render Passes
        guard let drawable = view.currentDrawable else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = clearColor
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            fatalError("Failed to create command buffer")
        }
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            fatalError("Failed to create render encoder")
        }
        
        renderEncoder.setRenderPipelineState(renderPipelineState)
        
        let vertexBuffer = device.makeBuffer(array: vertices)
        renderEncoder.setVertexBuffer(vertexBuffer,
                                      offset: 0,
                                      index: 0)
        
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: 3)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView,
                 drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        render()
    }
}

