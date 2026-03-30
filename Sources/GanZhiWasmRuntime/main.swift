import Foundation
import GanZhiWasmBridge

@_cdecl("ganzhi_alloc")
public func ganzhi_alloc(_ size: Int32) -> UnsafeMutableRawPointer? {
    guard size > 0 else {
        return nil
    }
    return UnsafeMutableRawPointer.allocate(byteCount: Int(size), alignment: 1)
}

@_cdecl("ganzhi_dealloc")
public func ganzhi_dealloc(_ ptr: UnsafeMutableRawPointer?, _ size: Int32) {
    guard size > 0, let ptr else {
        return
    }
    ptr.deallocate()
}

@_cdecl("ganzhi_analyze")
public func ganzhi_analyze(_ inputPtr: UnsafePointer<UInt8>?, _ inputLen: Int32) -> UnsafeMutablePointer<CChar>? {
    guard inputLen >= 0, let inputPtr else {
        return makeCString(from: GanZhiWasmBridge.analyze(requestJSON: "{}"))
    }

    let bytes = UnsafeBufferPointer(start: inputPtr, count: Int(inputLen))
    let request = String(decoding: bytes, as: UTF8.self)
    let response = GanZhiWasmBridge.analyze(requestJSON: request)
    return makeCString(from: response)
}

@_cdecl("ganzhi_free_string")
public func ganzhi_free_string(_ ptr: UnsafeMutablePointer<CChar>?) {
    ptr?.deallocate()
}

@_cdecl("ganzhi_string_len")
public func ganzhi_string_len(_ ptr: UnsafePointer<CChar>?) -> Int32 {
    guard let ptr else {
        return 0
    }

    var len: Int32 = 0
    while ptr[Int(len)] != 0 {
        len += 1
    }
    return len
}

private func makeCString(from string: String) -> UnsafeMutablePointer<CChar>? {
    let cString = Array(string.utf8CString)
    let output = UnsafeMutablePointer<CChar>.allocate(capacity: cString.count)
    output.initialize(from: cString, count: cString.count)
    return output
}
