//
//  MTKRectangleViewController.swift
//  Metal-UIKit-Study
//
//  Created by 이전희 on 5/22/24.
//

import UIKit
import MetalKit

class MTKRectangleViewController: UIViewController {
    var mtkView: MTKView = MTKView(frame: .zero)
    
    var renderer: Renderer = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        addSubviews()
        makeConstraints()
        
        self.mtkView.enableSetNeedsDisplay = true
        self.mtkView.device = self.renderer.device
        self.mtkView.delegate = self.renderer
        mtkView.depthStencilStorageMode = .memoryless
    }
    
    private func configure() {
        
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
}


class Renderer: NSObject {
    var device:MTLDevice!
    var commandQueue: MTLCommandQueue!
    
    var imageVertexBuffer: MTLBuffer!
    var imagePipelineState: MTLRenderPipelineState!
    var imageDepthState:MTLDepthStencilState!
    var imageTexture: MTLTexture?
    
    var imageVertexFunction: MTLFunction!
    var imageFragmentFunction: MTLFunction!
    
    let kImagePlaneVertexData:[Float] = [
        -1.0, -1.0, 0.0, 1.0,
         1.0, -1.0, 1.0, 1.0,
         -1.0, 1.0, 0.0, 0.0,
         1.0, 1.0, 1.0, 0.0,
    ]
    
    
    override init() {
        super.init()
        
        self.device = MTLCreateSystemDefaultDevice()
        initMetal()
    }
    
    func initMetal() {
        guard let defaultLibrary = try? self.device.makeDefaultLibrary(bundle: Bundle(for: Renderer.self)) else {
            print("[Renderer.initMetal] init error")
            return
        }
        
        imageVertexFunction = defaultLibrary.makeFunction(name: "imageVertexFunction")
        imageFragmentFunction = defaultLibrary.makeFunction(name: "imageFragmentFunction")
        
        self.commandQueue = self.device.makeCommandQueue()
        
        let size = kImagePlaneVertexData.count * MemoryLayout<Float>.size
        imageVertexBuffer = self.device.makeBuffer(bytes: kImagePlaneVertexData, length: size)
        imageVertexBuffer.label = "ImageVertexBuffer"
        
        
        let imageVertexDescriptor = MTLVertexDescriptor()
        imageVertexDescriptor.attributes[0].format = .float2
        imageVertexDescriptor.attributes[0].offset = 0
        imageVertexDescriptor.attributes[0].bufferIndex = 0
        imageVertexDescriptor.attributes[1].format = .float2
        imageVertexDescriptor.attributes[1].offset = 8
        imageVertexDescriptor.attributes[1].bufferIndex = 0
        imageVertexDescriptor.layouts[0].stride = 16
        imageVertexDescriptor.layouts[0].stepRate = 1
        imageVertexDescriptor.layouts[0].stepFunction = .perVertex
        
        
        let imagePipelineDescriptor = MTLRenderPipelineDescriptor()
        imagePipelineDescriptor.label = "ImageRenderPipeline"
        // imagePipelineDescriptor.sampleCount = 1
        imagePipelineDescriptor.vertexFunction = imageVertexFunction
        imagePipelineDescriptor.fragmentFunction = imageFragmentFunction
        imagePipelineDescriptor.vertexDescriptor = imageVertexDescriptor
        imagePipelineDescriptor.depthAttachmentPixelFormat = .invalid
        imagePipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            try self.imagePipelineState = self.device.makeRenderPipelineState(descriptor: imagePipelineDescriptor)
        } catch let error {
            print("error=\(error.localizedDescription)")
        }
        
        // depth state
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .lessEqual
        depthDescriptor.isDepthWriteEnabled = true
        
        self.imageDepthState =  self.imagePipelineState.device.makeDepthStencilState(descriptor: depthDescriptor)
        
        self.imageTexture = loadTexture()
        
    }
    
    func render(view:MTKView) {
        print("render")
        
        guard let renderPass = view.currentRenderPassDescriptor else { return }
        guard let drawable = view.currentDrawable else { return }
        guard let commandBuffer = self.commandQueue.makeCommandBuffer() else { return }
        commandBuffer.label = "RenderCommand"
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass) else {
            return
        }
        
        
        renderEncoder.label = "RenderEncoder"
        renderEncoder.setCullMode(.front)
        renderEncoder.setDepthStencilState(self.imageDepthState)
        renderEncoder.setRenderPipelineState(self.imagePipelineState)
        
        renderEncoder.setVertexBuffer(self.imageVertexBuffer, offset: 0, index: 0)
        
        // 프래그먼트 세이더에 텍스처 전달
        renderEncoder.setFragmentTexture(self.imageTexture!, index: 0)
        
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func loadTexture() -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)
        guard let cgImage = UIImage(named: "cat")?.cgImage else { return  nil }
        return try? textureLoader.newTexture(cgImage: cgImage)
    }
}

extension Renderer:MTKViewDelegate {
    func draw(in view: MTKView) {
        self.render(view: view)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize ) {
    }
}
