//
//  MTKBaseViewController.swift
//  Metal-UIKit-Study
//
//  Created by 이전희 on 5/22/24.
//

import UIKit
import MetalKit

class MTKBaseViewController: UIViewController {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    
    var vertexFunction: MTLFunction!
    var fragmentFunction: MTLFunction!
    
    let vertexData: [Float] = [
        0, 1,
        -1, 0,
        1, 0
    ]
    
    let colorData: [Float] = [
        1, 0, 0, 0.5, // rgba
        0, 1, 0, 0.5,
        0, 0, 1, 0.5
    ]
    
    var mtkView: MTKView {
        self.view as! MTKView
    }
    
    override func loadView() {
        self.view = MTKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        mtkSetup()
    }
    
    func mtkSetup() {
        // 1. create MTLDevice (connect GPU)
        // 2. create MTLBuffer (CPU -> GPU)
        // 3. create MTLRedenrPipeline (the pipeline that set config; shader, color attachment format...)
        
        mtkView.delegate = self
        mtkView.enableSetNeedsDisplay = true // 뷰가 contents의 업데이트가 필요할때만 draw
        mtkView.clearColor = MTLClearColorMake(0, 0, 0, 1.0)
        
        // 1. MTLDevice
        device = MTLCreateSystemDefaultDevice()
        mtkView.device = device
        
        // 2. Command Queue, Buffer, Encoder
        commandQueue = device.makeCommandQueue() // 여러 개의 Command Queue를 묶은 것
        // CommandBuffer: 여러개의 Command Encoder를 묶은 것, 매 프레임마다 생성
        // CommandEncoder: 전달한 버퍼의 내용 중 n -> k번째까지를 버텍스로 쓰고, primitive를 어떤 걸 사용할 지 등의 렌더링 커맨드
        
        // 3. MTLBuffer
        /*
         let dataSize = vertexData.count * MemoryLayout.size(ofValue: _vertexData[0])
         vertexBuffer = device.makeBuffer(bytes: vertexData,
         length: dataSize,
         options: [])
         */
        
        
        // 4. Shader
        let defaultLibrary = device.makeDefaultLibrary()!
        vertexFunction = defaultLibrary.makeFunction(name: "vertexPassThroughShader")
        fragmentFunction = defaultLibrary.makeFunction(name: "fragmentPassThroughShader")
        
        // 5. RenderingPipelineState
        // MTLRenderPipelineDescriptor: Rendering Pipeline Configure
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        pipelineState = try! device.makeRenderPipelineState(descriptor:  pipelineStateDescriptor)
    }
    
    private func render() {
        // MARK: - loop

        // 6. Render Passes
        guard let drawable = mtkView.currentDrawable else { return }
        guard let renderDescriptor = mtkView.currentRenderPassDescriptor else { return }
        renderDescriptor.colorAttachments[0].texture = drawable.texture
        renderDescriptor.colorAttachments[0].loadAction = .clear // 매 렌더패스마다 초기화
        renderDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        
        //  커맨드버퍼는 하나 이상의 렌더 커맨드를 담고 있어야 한다.
        let commandBuffer = commandQueue.makeCommandBuffer()!
    
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        
        
        
        let vertexDataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        let vertexBuffer = device.makeBuffer(bytes: vertexData,
                                             length: vertexDataSize,
                                             options: [])
        
        let colorDataSize = colorData.count * MemoryLayout.size(ofValue: colorData[0])
        let colorBuffer = device.makeBuffer(bytes: colorData,
                                            length: colorDataSize,
                                            options: [])
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: 3,
                                     instanceCount: 1)
        renderEncoder.endEncoding()
        
        // commit
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension MTKBaseViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        print(#function)
        render()
    }
}
