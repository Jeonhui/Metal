//
//  MTK3DRenderer.swift
//  Metal-Cube
//
//  Created by Jeonhui on 5/24/24
//


import MetalKit

class MTK3DRenderer: NSObject {
    weak var view: MTKView!
    
    var windowSize: CGSize!
    var aspectRatio: Float!
    
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
    
    let vertices: [Texture2DVertex] = [
        Texture2DVertex(position: .bottomLeft.half(), texCoord: .bottomLeft),
        Texture2DVertex(position: .bottomRight.half(), texCoord: .bottomRight),
        Texture2DVertex(position: .topRight.half(), texCoord: .topRight),
        Texture2DVertex(position: .topLeft.half(), texCoord: .topLeft)
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
              let vertexFunction = library.makeFunction(name: "vertexQuadFunction"),
              let fragmentFunction = library.makeFunction(name: "fragmentQuadFunction") else {
            fatalError("Failed to create Shader")
        }
        self.library = library
        self.vertexFunction = vertexFunction
        self.fragmentFunction = fragmentFunction
        
        // 4. Pipeline state
        
        // VertexDescriptor
        let vertexDescriptor = MTLVertexDescriptor()
        
        // Most higher buffer index = 30, 다른 버퍼를 위해 0번째 슬롯을 비울 수 있도록 하며 .perVertex를 통해 vertex 단위로 진행
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
        
        var projectionMatrix = createPerspectiveMatrix(fov: toRadians(from: 45.0),
                                                       aspectRatio: aspectRatio,
                                                       nearPlane: 0.1,
                                                       farPlane: 100.0)
        renderEncoder.setVertexBytes(&projectionMatrix,
                                     length: MemoryLayout.stride(ofValue: projectionMatrix),
                                     index: 0)
        
        //Create the view matrix
        let viewMatrix = createViewMatrix(eyePosition: simd_float3(0.0, 5.0, -5.0), targetPosition: simd_float3(0.0, 0.0, 0.0), upVec: simd_float3(0.0, 1.0, 0.0))

        //Create the model matrix
        var modelMatrix = matrix_identity_float4x4
        translateMatrix(matrix: &modelMatrix, 
                        position: simd_float3(0.0, 0.0, 0.0))
        rotateMatrix3D(matrix: &modelMatrix,
                       rotation: simd_float3(0.0, toRadians(from: 60.0), 0.0))
        scaleMatrix(matrix: &modelMatrix, 
                    scale: simd_float3(1.0, 1.0, 1.0))

        var modelViewMatrix = viewMatrix * modelMatrix
        renderEncoder.setVertexBytes(&modelViewMatrix,
                                     length: MemoryLayout.stride(ofValue: modelViewMatrix),
                                     index: 1)
        
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

extension MTK3DRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView,
                 drawableSizeWillChange size: CGSize) {
        self.windowSize = size
        self.aspectRatio = Float(self.windowSize.width) / Float(self.windowSize.height)
    }
    
    func draw(in view: MTKView) {
        render()
    }
}

