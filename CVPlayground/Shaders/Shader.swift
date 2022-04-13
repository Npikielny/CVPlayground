//
//  Shader.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/12/22.
//

import MetalKit

class BaseShader<BufferKey: Hashable, TextureKey: Hashable>: NSObject, Shader {
    private var buffers: [BufferKey: MTLBuffer]
    private var textures: [TextureKey: MTLTexture]
    var device: MTLDevice
    var queue: MTLCommandQueue
    private var library: MTLLibrary
    var runType: RunType
    var needsDraw = true
    var semaphore = DispatchSemaphore(value: 1)
    
    subscript(_ key: BufferKey) -> MTLBuffer? {
        get { buffers[key] }
        set { buffers[key] = newValue }
    }
    
    subscript(_ key: TextureKey) -> MTLTexture? {
        get { textures[key] }
        set { textures[key] = newValue }
    }
    
    var pipeline: [Pipeline<BufferKey, TextureKey>]
    
    init?(
        device: MTLDevice,
        buffers: [BufferKey: MTLBuffer] = [:],
        textures: [TextureKey: MTLTexture] = [:],
        pipeline: [Pipeline<BufferKey, TextureKey>],
        runType: RunType = .single
    ) {
        self.buffers = buffers
        self.textures = textures
        self.device = device
        self.pipeline = pipeline
        guard let queue = device.makeCommandQueue() else { print("failed making queue"); return nil }
        guard let library = device.makeDefaultLibrary() else { print("failed making queue"); return nil }
        self.queue = queue
        self.library = library
        self.runType = runType
    }
    
    init?(
        device: MTLDevice,
        buffers: (MTLDevice) -> [BufferKey: MTLBuffer] = { _ in return [:] },
        textures: (MTLDevice) -> [TextureKey: MTLTexture] = { _ in return [:] },
        pipeline: [Pipeline<BufferKey, TextureKey>],
        runType: RunType = .single
    ) {
        self.device = device
        self.buffers = buffers(device)
        self.textures = textures(device)
        self.pipeline = pipeline
        guard let queue = device.makeCommandQueue() else { print("failed making queue"); return nil }
        guard let library = device.makeDefaultLibrary() else { print("failed making queue"); return nil }
        self.queue = queue
        self.library = library
        self.runType = runType
    }
    
    convenience init?(
        runType: BaseShader<BufferKey, TextureKey>.RunType = .single,
        buffers: (MTLDevice) -> [BufferKey: MTLBuffer],
        textures: (MTLDevice) -> [TextureKey: MTLTexture],
        pipeline: ((String, MTLFunctionConstantValues?) -> MTLFunction?, MTLDevice) -> [Pipeline<BufferKey, TextureKey>]?
    ) {
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        self.init(device: device, buffers: buffers(device), textures: textures(device), pipeline: [], runType: runType)
        guard let pipeline = pipeline(createFunction(name:constants:), device) else { print("failed making pipeline"); return nil }
        self.pipeline = pipeline
    }
    
    func createFunction(name: String, constants: MTLFunctionConstantValues? = nil) -> MTLFunction? {
        if let constants = constants {
            do {
                return try library.makeFunction(name: name, constantValues: constants)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        } else {
            return library.makeFunction(name: name)
        }
    }
    
    enum RunType {
        case single
        case continuous
    }
    
    func executeInstruction(
        instruction: Pipeline<BufferKey, TextureKey>,
        texture: MTLTexture,
        renderPassDescriptor: MTLRenderPassDescriptor,
        commandBuffer: MTLCommandBuffer
    ) {
        switch instruction {
            case let .render(pipelineState, instructions):
                instructions(self, texture, renderPassDescriptor, commandBuffer, pipelineState)
            case let .compute(pipelineState, instructions):
                instructions(self, texture, renderPassDescriptor, commandBuffer, pipelineState)
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        if runType == .continuous || needsDraw {
            guard let commandBuffer = queue.makeCommandBuffer() else { print("failed making command buffer"); return }
            guard let drawable = view.currentDrawable else { print("failed getting drawable"); return }
            guard let renderPassDescriptor = view.currentRenderPassDescriptor else { print("failed getting render pass descriptor"); return }
            needsDraw = false
            commandBuffer.addCompletedHandler { [self] _ in
                semaphore.signal()
            }
            
            for instruction in pipeline {
                executeInstruction(instruction: instruction, texture: drawable.texture, renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer)
            }
            commandBuffer.present(drawable)
            commandBuffer.commit()
            semaphore.wait()
        }
    }
    
    enum Pipeline<BufferKey: Hashable, TextureKey: Hashable> {
        typealias PerFrameInstructions<PipelineState> = (
            BaseShader<BufferKey, TextureKey>,
            _ texture: MTLTexture,
            _ renderPassDescriptor: MTLRenderPassDescriptor,
            _ commandBuffer: MTLCommandBuffer,
            _ pipelineState: PipelineState
        ) -> Void
        
        case compute(pipelineState: MTLComputePipelineState, instructions: PerFrameInstructions<MTLComputePipelineState>)
        case render(pipelineState: MTLRenderPipelineState, instructions: PerFrameInstructions<MTLRenderPipelineState>)
    }
}

protocol Shader: MTKViewDelegate {
    associatedtype BufferKey: Hashable
    associatedtype TextureKey: Hashable
    
    var device: MTLDevice { get }
}

typealias ResourcelessShader = BaseShader<String, String>
