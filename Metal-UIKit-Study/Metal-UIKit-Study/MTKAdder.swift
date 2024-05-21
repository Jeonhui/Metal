//
//  MTKAdder.swift
//  Metal-UIKit-Study
//
//  Created by 이전희 on 5/21/24.
//

import Foundation
import Metal

class MetalAdder {
    
    let device: MTLDevice
    // queue for sending to GPU
    let commandQueue: MTLCommandQueue?
    // pipeline for converting the proxy(non-excutable code) of MSL(Metal Shading Language) function  into an excutable code
    var pipeLineState: MTLComputePipelineState?
    
    // buffer for adding
    var bufferA: MTLBuffer?
    var bufferB: MTLBuffer?
    var bufferResult: MTLBuffer?
    var arrayLength: Int?
    
    init() {
        self.device = MTLCreateSystemDefaultDevice()!
        self.commandQueue = device.makeCommandQueue()!
        setupPipeLineState()
    }
    
    private func setupPipeLineState() {
        guard let defaultLibrary: MTLLibrary = device.makeDefaultLibrary() else {
            return print("Failed to find the default library.")
        }
        
        guard let addFunction: MTLFunction = defaultLibrary.makeFunction(name: "add_arrays") else {
            return print("Failed to find the adder function.")
        }
        
        if let pipeLineState: MTLComputePipelineState = try? device.makeComputePipelineState(function: addFunction) {
            self.pipeLineState = pipeLineState
        } else {
            return print("Failed to created pipeline state object")
        }
    }
    
    
    func prepareData(firstArray: [Float],
                     secondArray: [Float],
                     arrayLength: Int) {
        
        // Allocate three buffers to hold our initial data and the result.
        // buffer size
        let bufferSize = arrayLength * MemoryLayout<Float>.size
        
        // set buffer
        // .storageModeShared: all access(CPU, GPU)
        //
        bufferA = device.makeBuffer(length: bufferSize,
                                    options: .storageModeShared)
        bufferB = device.makeBuffer(length: bufferSize,
                                    options: .storageModeShared)
        bufferResult = device.makeBuffer(length: bufferSize,
                                         options: .storageModeShared)
        
        bufferA?.contents().copyMemory(from: firstArray, byteCount: bufferSize)
        bufferB?.contents().copyMemory(from: secondArray, byteCount: bufferSize)
        
        
        /* other code
         bufferA = device.makeBuffer(bytes: firstArray,
         length: bufferSize,
         options: .storageModeShared)
         bufferB = device.makeBuffer(bytes: secondArray,
         length: bufferSize,
         options: .storageModeShared)
         bufferResult = device.makeBuffer(length: bufferSize,
         options: .storageModeShared)
         */
        
        self.arrayLength = arrayLength
    }
    
    func sendAddCommand() {
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else { return }
        
        encodeAddCommand(to: commandBuffer)
        
        commandBuffer.commit()
        
        commandBuffer.waitUntilCompleted()
        
        let result = convertResult()
        print(result)
    }
    
    private func encodeAddCommand(to commandBuffer: MTLCommandBuffer) {
        guard let pipeLineState = pipeLineState,
              let arrayLength = arrayLength,
              let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
        
        // Encode the pipeline state object and its parameters
        encoder.setComputePipelineState(pipeLineState)
        
        encoder.setBuffer(bufferA, offset: 0, index: 0)
        encoder.setBuffer(bufferB, offset: 0, index: 1)
        encoder.setBuffer(bufferResult, offset: 0, index: 2)
        
        // Calculate a threadgroup size.
        let gridSize = MTLSizeMake(arrayLength, 1, 1)
        let threadGroupSize = MTLSizeMake(pipeLineState.maxTotalThreadsPerThreadgroup, 1, 1)
        
        encoder.dispatchThreadgroups(gridSize,
                                     threadsPerThreadgroup: threadGroupSize)
        
        // Encode the compute command.
        encoder.endEncoding()
        
        /*
         {PSO Argument Argument CommentArguemnt}
         ↓
         Command Encoder
         ↓
         Command Buffer
         */
    }
    
    private func convertResult() -> [CGFloat] {
        let result = (0..<arrayLength!).map {
            let value = bufferResult!
                .contents()
                .load(fromByteOffset: MemoryLayout<Float>.size * $0,
                      as: Float.self)
            return CGFloat(value)
        }
        return result
    }
}
