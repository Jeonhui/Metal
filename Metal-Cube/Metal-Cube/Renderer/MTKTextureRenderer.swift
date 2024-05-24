//
//  MTKTextureRenderer.swift
//  Metal-Cube
//
//  Created by Jeonhui on 5/24/24
//


import MetalKit

class MTKTextureRenderer: NSObject {
    weak var view: MTKView!
    
    let device: MTLDevice
    
    let commandQueue: MTLCommandQueue
    
    let library: MTLLibrary
    var vertexFunction: MTLFunction
    var fragmentFunction: MTLFunction
    
    var renderPipelineState: MTLRenderPipelineState
    
    var clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
    var indexBuffer: MTLBuffer!
    
    var textureLoader: MTKTextureLoader?
    var textures: [String: MTLTexture] = [:]
    
    // let vertices: [Vertex] = [
    //     Vertex(position: .init(x: -0.5, y: -0.5), uiColor: .red),
    //     Vertex(position: .init(x: 0.5, y: -0.5), uiColor: .green),
    //     Vertex(position: .init(x: 0.5, y: 0.5), uiColor: .blue),
    //     Vertex(position: .init(x: -0.5, y: -0.5), uiColor: .red),
    //     Vertex(position: .init(x: 0.5, y: 0.5), uiColor: .green),
    //     Vertex(position: .init(x: -0.5, y: 0.5), uiColor: .green)
    // ]
    
    // 3b (-1, 1)    (0, 1)    2b (1, 1)
    //    (-1, 0)    (0, 0)       (1, 0)
    // 0r (-1, -1)   (0, -1)   1r (1, -1)
    
    // let vertices: [Vertex] = [
    //     Vertex(position: .init(x: -0.5, y: -0.5), uiColor: .red),
    //     Vertex(position: .init(x: 0.5, y: -0.5), uiColor: .red),
    //     Vertex(position: .init(x: 0.5, y: 0.5), uiColor: .blue),
    //     Vertex(position: .init(x: -0.5, y: 0.5), uiColor: .blue)
    // ]
    
    let vertices: [Texture2DVertex] = [
        Texture2DVertex(position: .bottomLeft, texCoord: .bottomLeft),
        Texture2DVertex(position: .bottomRight, texCoord: .bottomRight),
        Texture2DVertex(position: .topRight, texCoord: .topRight),
        Texture2DVertex(position: .topLeft, texCoord: .topLeft)
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
              let vertexFunction = library.makeFunction(name: "vertexTextureSquare"),
              let fragmentFunction = library.makeFunction(name: "fragmentTextureSquare") else {
            fatalError("Failed to create Shader")
        }
        self.library = library
        self.vertexFunction = vertexFunction
        self.fragmentFunction = fragmentFunction
        
        // 4. Pipeline state
        
        // VertexDescriptor
        let vertexDescriptor = MTLVertexDescriptor()
        
        // Most higher buffer index = 30
        vertexDescriptor.layouts[30].stride = MemoryLayout<Vertex>.stride
        vertexDescriptor.layouts[30].stepRate = 1
        vertexDescriptor.layouts[30].stepFunction = .perVertex
        
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = MemoryLayout.offset(of: \Vertex.position)!
        vertexDescriptor.attributes[0].bufferIndex = 30
        
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout.offset(of: \Vertex.color)!
        vertexDescriptor.attributes[1].bufferIndex = 30
        
        let renderPipelineStateDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineStateDescriptor.vertexFunction = vertexFunction
        renderPipelineStateDescriptor.fragmentFunction = fragmentFunction
        renderPipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        renderPipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        
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
        
        let indices: [ushort] = [
            0, 1, 2,
            0, 2, 3
        ]
        
        let indexBuffer = device.makeBuffer(array: indices)!
        let vertexBuffer = device.makeBuffer(array: vertices)
        
        renderEncoder.setVertexBuffer(vertexBuffer,
                                      offset: 0,
                                      index: 30)
        
        renderEncoder.setFragmentTexture(textures["cat"], index: 0)
        
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: 6,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
        
        // renderEncoder.drawPrimitives(type: .triangle,
        //                              vertexStart: 0,
        //                              vertexCount: 6)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private func setLoader() {
        guard textureLoader == nil else { return }
        textureLoader = MTKTextureLoader(device: self.device)
    }
    
    func addTexture(name: String,
                    uiImage: UIImage,
                    options: [MTKTextureLoader.Option: Any]? = [:]) throws {
        setLoader()
        guard let cgImage = uiImage.cgImage else {
            fatalError("Failed to convert UIImage to CGImage")
        }
        let texture = try textureLoader?.newTexture(cgImage: cgImage,
                                                    options: options)
        self.textures[name] = texture
    }
}

extension MTKTextureRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView,
                 drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        render()
    }
}

