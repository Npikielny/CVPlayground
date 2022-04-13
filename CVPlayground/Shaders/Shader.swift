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
        
        struct PipelineError: Error {
            var description: String
        }
        
        func retrieveResources(buffers: [BufferKey], textures: [TextureKey], shader: BaseShader<BufferKey, TextureKey>) throws -> (buffers: [MTLBuffer], textures: [MTLTexture]) {
            let buffers: [MTLBuffer] = try buffers.map { bufferKey in
                guard let buffer = shader[bufferKey] else {
                    throw PipelineError(description: "Failed getting buffer \(bufferKey)")
                }
                return buffer
            }
            let textures: [MTLTexture] = try textures.map { textureKey in
                guard let texture = shader[textureKey] else {
                    throw PipelineError(description: "Failed getting buffer \(textureKey)")
                }
                return texture
            }
            return (buffers, textures)
        }
        
        func compute(
            name: String,
            create: (String) -> MTLFunction?,
            device: MTLDevice,
            buffers: [BufferKey],
            textures: [TextureKey],
            bytes: [Packet],
            threadSize: MTLSize,
            totalSize: MTLSize
        ) -> Self? {
            guard let function = create(name),
                  let pipeline = try? device.makeComputePipelineState(function: function) else { return nil }
            return .compute(pipelineState: pipeline) { shader, texture, renderPassDescriptor, commandBuffer, pipelineState in
                guard let encoder = commandBuffer.makeComputeCommandEncoder() else { print("failed making encoder"); return }
                do {
                    let (buffers, textures) = try retrieveResources(buffers: buffers, textures: textures, shader: shader)
                    encoder.setBuffers(buffers, offsets: Array(repeating: 0, count: buffers.count), range: 0..<buffers.count)
                    encoder.setTextures(textures, range: 0..<textures.count)
                } catch {
                    print(error)
                    return
                }
                bytes.computeBytes(encoder, offset: buffers.count)
                
                encoder.dispatchThreadgroups(threadGroupSize: threadSize, totalSize: totalSize)
            }
        }
        
        func render(
            vertexFunction: String,
            fragmentFunction: String,
            pixelFormat: MTLPixelFormat = .bgra8Unorm,
            create: (String) -> MTLFunction?,
            device: MTLDevice,
            vertexBuffers: [BufferKey],
            vertexTextures: [TextureKey],
            fragmentBuffers: [BufferKey],
            fragmentTextures: [TextureKey],
            vertexBytes: [Packet],
            fragmentBytes: [Packet],
            threadSize: MTLSize,
            totalSize: MTLSize
        ) -> Self? {
            guard let vertexFunction = create(vertexFunction),
                  let fragmentFunction = create(fragmentFunction) else { return nil }
            
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = fragmentFunction
            descriptor.sampleCount = 1
            descriptor.colorAttachments[0].pixelFormat = pixelFormat
            guard let pipeline = try? device.makeRenderPipelineState(descriptor: descriptor) else { return nil }
            
            return .render(pipelineState: pipeline) { shader, texture, renderPassDescriptor, commandBuffer, pipelineState in
                guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
                do {
                    let (vertexBuffers, vertexTextures) = try retrieveResources(buffers: vertexBuffers, textures: vertexTextures, shader: shader)
                    encoder.setVertexBuffers(vertexBuffers, offsets: Array(repeating: 0, count: vertexBuffers.count), range: 0..<vertexBuffers.count)
                    encoder.setFragmentTextures(vertexTextures, range: 0..<vertexTextures.count)
                    vertexBytes.vertexBytes(encoder, offset: vertexBuffers.count)
                    
                    let (fragmentBuffers, fragmentTextures) = try retrieveResources(buffers: fragmentBuffers, textures: fragmentTextures, shader: shader)
                    encoder.setFragmentBuffers(fragmentBuffers, offsets: Array(repeating: 0, count: fragmentBuffers.count), range: 0..<fragmentBuffers.count)
                    encoder.setFragmentTextures(fragmentTextures, range: 0..<fragmentTextures.count)
                    vertexBytes.fragmentBytes(encoder, offset: fragmentBuffers.count)
                } catch {
                    print(error)
                    return
                }
            }
        }
    }
}

protocol Shader: MTKViewDelegate {
    associatedtype BufferKey: Hashable
    associatedtype TextureKey: Hashable
    
    var device: MTLDevice { get }
}

typealias ResourcelessShader = BaseShader<String, String>
