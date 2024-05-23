//
//  MTKCubeViewController.swift
//  Metal-UIKit-Study
//
//  Created by 이전희 on 5/22/24.
//

import UIKit
import MetalKit

// MARK: - MTKCubeViewController
class MTKCubeViewController: UIViewController {
    
    let mtkView: MTKView = MTKView()
    var renderer: Renderer!
    
    override func loadView() {
        print(#function)
        self.view = mtkView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        configure()
        addSubviews()
        makeConstraints()
    }
    
    private func configure() {
        renderer = Renderer(mtkView)
    }
    
    private func addSubviews() {
        
    }
    
    private func makeConstraints() {
        
    }
}

// MARK: - Renderer
class Renderer: NSObject {
    weak var view: MTKView!
    weak var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var mesh: MTKMesh!
    var vertexBuffer: MTLBuffer!
    var timer: Float = 0
    
    init(_ view: MTKView) {
        super.init()
        
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError()
        }
        self.view = view
        view.delegate = self
        self.device = device
        view.device = self.device
        view.clearColor = MTLClearColor(red: 1.0,
                                        green: 1.0,
                                        blue: 1.0,
                                        alpha: 1.0)
        self.commandQueue = commandQueue
        setupData()
    }
    
    // Mesh 생성 및 MTLVertexBuffer 생성
    func setupData() {
        let mdlMesh = Primitive.makeCube(device: device,
                                         size: 1)

        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
        } catch let error {
            print(error.localizedDescription)
        }

        vertexBuffer = mesh.vertexBuffers[0].buffer

        // 4. MTLRenderPipelineState 생성. 각 쉐이더를 디스크립터로 지정해서 config를 생성하고, 이 config(descriptor)를 바탕으로 렌더링 파이프라인을 생성한다.
        let defaultLibrary = device.makeDefaultLibrary()!      // 미리 컴파일한 쉐이더에 접근가능하게 만들어줌.
        let fragmentProgram = defaultLibrary.makeFunction(name: "fragment_cube")   // frag shader. shader function name설정
        let vertexProgram = defaultLibrary.makeFunction(name: "vertex_cube")       // vert shader. shader function name설정

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor() // 렌더링 파이프라인의 config를 설정해줌.
        pipelineStateDescriptor.vertexFunction = vertexProgram      // 파이프라인에서 사용하는 각각의 쉐이더를 지정해주고,
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func render(_ view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        // drawing code -----
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        
        timer += 0.05
        var currentTime = sin(timer)
        renderEncoder.setVertexBytes(&currentTime,
                                     length: MemoryLayout<Float>.stride,
                                     index: 1)
    
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: submesh.indexCount,
                                                indexType: submesh.indexType,
                                                indexBuffer: submesh.indexBuffer.buffer,
                                                indexBufferOffset: submesh.indexBuffer.offset)
        }
        // -----------
        renderEncoder.endEncoding()
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        render(view)
    }
}


// MARK: - Primitive
class Primitive {
    static func makeCube(device: MTLDevice, size: Float) -> MDLMesh {
        let allocator = MTKMeshBufferAllocator(device: device)
        let mesh = MDLMesh(sphereWithExtent: [size, size, size],
                           segments: [1, 1],
                           inwardNormals: false,
                           geometryType: .triangles,
                           allocator: allocator)
        return mesh
    }
}
