//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-memcache-gsoc open source project
//
// Copyright (c) 2023 Apple Inc. and the swift-memcache-gsoc project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of swift-memcache-gsoc project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import NIOCore
@testable import SwiftMemcache
import XCTest

@available(macOS 13.0, *)
final class MemcachedRequestEncoderTests: XCTestCase {
    var encoder: MemcachedRequestEncoder!

    override func setUp() {
        super.setUp()
        self.encoder = MemcachedRequestEncoder()
    }

    func testEncodeSetRequest() {
        // Prepare a MemcachedRequest
        var buffer = ByteBufferAllocator().buffer(capacity: 2)
        buffer.writeString("hi")
        let command = MemcachedRequest.SetCommand(key: "foo", value: buffer)
        let request = MemcachedRequest.set(command)

        // pass our request through the encoder
        var outBuffer = ByteBufferAllocator().buffer(capacity: 0)
        do {
            try self.encoder.encode(data: request, out: &outBuffer)
        } catch {
            XCTFail("Encoding failed with error: \(error)")
        }

        let expectedEncodedData = "ms foo 2\r\nhi\r\n"
        XCTAssertEqual(outBuffer.getString(at: 0, length: outBuffer.readableBytes), expectedEncodedData)
    }

    func testEncodeSetTTLRequest() {
        // Prepare a MemcachedRequest
        var buffer = ByteBufferAllocator().buffer(capacity: 2)
        buffer.writeString("hi")
        var flags = MemcachedFlags()

        let clock = ContinuousClock()
        flags.timeToLive = .expiresAt(clock.now.advanced(by: Duration.seconds(90)))
        let command = MemcachedRequest.SetCommand(key: "foo", value: buffer, flags: flags)
        let request = MemcachedRequest.set(command)

        // pass our request through the encoder
        var outBuffer = ByteBufferAllocator().buffer(capacity: 0)
        do {
            try self.encoder.encode(data: request, out: &outBuffer)
        } catch {
            XCTFail("Encoding failed with error: \(error)")
        }

        let expectedEncodedData = "ms foo 2 T89\r\nhi\r\n"
        XCTAssertEqual(outBuffer.getString(at: 0, length: outBuffer.readableBytes), expectedEncodedData)
    }

    func testEncodeGetRequest() {
        // Prepare a MemcachedRequest
        var flags = MemcachedFlags()
        flags.shouldReturnValue = true
        let command = MemcachedRequest.GetCommand(key: "foo", flags: flags)

        let request = MemcachedRequest.get(command)

        // Pass our request through the encoder
        var outBuffer = ByteBufferAllocator().buffer(capacity: 0)
        do {
            try self.encoder.encode(data: request, out: &outBuffer)
        } catch {
            XCTFail("Encoding failed with error: \(error)")
        }

        let expectedEncodedData = "mg foo v\r\n"
        XCTAssertEqual(outBuffer.getString(at: 0, length: outBuffer.readableBytes), expectedEncodedData)
    }
}
