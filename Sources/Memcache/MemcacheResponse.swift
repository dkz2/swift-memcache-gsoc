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

struct MemcacheResponse {
    enum ReturnCode {
        case HD
        case NS
        case EX
        case NF
        case VA
        case EN
        case MN

        init(_ bytes: UInt16) {
            switch bytes {
            case 0x4844:
                self = .HD
            case 0x4E53:
                self = .NS
            case 0x4558:
                self = .EX
            case 0x4E46:
                self = .NF
            case 0x5641:
                self = .VA
            case 0x454E:
                self = .EN
            case 0x4D4E:
                self = .MN
            default:
                preconditionFailure("Unrecognized response code.")
            }
        }
    }

    var returnCode: ReturnCode
    var dataLength: UInt64?
    var flags: MemcacheFlags?
    var value: ByteBuffer?
}
