//
//  MD5.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 3/30/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

/*
 This is a modified version of SwiftMD5.
 The origin repository is https://github.com/mpurland/SwiftMD5
 The following is the origin license:

 Copyright (c) 2016, Matthew Purland
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 * Neither the name of the {organization} nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation

class MD5 {
    typealias Byte = UInt8
    typealias Word = UInt32

    private static func F(_ b: Word, _ c: Word, _ d: Word) -> Word {
        return (b & c) | ((~b) & d)
    }

    private static func G(_ b: Word, _ c: Word, _ d: Word) -> Word {
        return (b & d) | (c & (~d))
    }

    private static func H(_ b: Word, _ c: Word, _ d: Word) -> Word {
        return b ^ c ^ d
    }

    private static func I(_ b: Word, _ c: Word, _ d: Word) -> Word {
        return c ^ (b | (~d))
    }

    private static func rotateLeft(_ x: Word, by: Word) -> Word {
        return ((x << by) & 0xFFFFFFFF) | (x >> (32 - by))
    }

    static func calculate(_ bytes: [Byte]) -> [Byte] {
        // Initialization
        let s: [Word] = [
            7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
            5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
            4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
            6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
        ]
        let K: [Word] = [
            0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
            0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
            0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
            0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
            0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
            0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
            0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
            0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
            0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
            0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
            0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
            0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
            0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
            0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
            0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
            0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
        ]

        var a0: Word = 0x67452301 // A
        var b0: Word = 0xefcdab89 // B
        var c0: Word = 0x98badcfe // C
        var d0: Word = 0x10325476 // D

        // Pad message with a single bit "1"
        var message = bytes

        let originalLength = bytes.count
        let bitLength = UInt64(originalLength * 8)

        message.append(0x80)

        // Pad message with bit "0" until message length is 64 bits fewer than 512
        repeat {
            message.append(0x0)
        } while (message.count * 8) % 512 != 448

        message.append(Byte((bitLength >> 0) & 0xFF))
        message.append(Byte((bitLength >> 8) & 0xFF))
        message.append(Byte((bitLength >> 16) & 0xFF))
        message.append(Byte((bitLength >> 24) & 0xFF))
        message.append(Byte((bitLength >> 32) & 0xFF))
        message.append(Byte((bitLength >> 40) & 0xFF))
        message.append(Byte((bitLength >> 48) & 0xFF))
        message.append(Byte((bitLength >> 56) & 0xFF))

        let newBitLength = message.count * 8

        assert(newBitLength % 512 == 0)

        // Transform

        let chunkLength = 512 // 512-bit
        let chunkLengthInBytes = chunkLength / 8 // 64-bytes
        let totalChunks = newBitLength / chunkLength

        assert(totalChunks >= 1)

        for chunk in 0..<totalChunks {
            let index = chunk*chunkLengthInBytes
            var chunk: [Byte] = Array(message[index..<index+chunkLengthInBytes]) // 512-bit/64-byte chunk

            // break chunk into sixteen 32-bit words
            var M: [Word] = []
            for j in 0..<16 {
                let m0 = Word(chunk[4*j+0]) << 0
                let m1 = Word(chunk[4*j+1]) << 8
                let m2 = Word(chunk[4*j+2]) << 16
                let m3 = Word(chunk[4*j+3]) << 24
                let m = Word(m0 | m1 | m2 | m3)

                M.append(m)
            }

            assert(M.count == 16)

            var A: Word = a0
            var B: Word = b0
            var C: Word = c0
            var D: Word = d0

            for i in 0..<64 {
                var f: Word = 0
                var g: Int = 0

                if i < 16 {
                    f = F(B, C, D)
                    g = i
                } else if i >= 16 && i <= 31 {
                    f = G(B, C, D)
                    g = ((5*i + 1) % 16)
                } else if i >= 32 && i <= 47 {
                    f = H(B, C, D)
                    g = ((3*i + 5) % 16)
                } else if i >= 48 && i <= 63 {
                    f = I(B, C, D)
                    g = ((7*i) % 16)
                }

                let dTemp = D
                D = C
                C = B

                let x = A &+ f &+ K[i] &+ M[g]
                let by = s[i]

                B = B &+ rotateLeft(x, by: by)
                A = dTemp
            }

            a0 = a0 &+ A
            b0 = b0 &+ B
            c0 = c0 &+ C
            d0 = d0 &+ D
        }

        assert(a0 >= 0)
        assert(b0 >= 0)
        assert(c0 >= 0)
        assert(d0 >= 0)

        let digest0: Byte =   Byte((a0 >> 0) & 0xFF)
        let digest1: Byte =   Byte((a0 >> 8) & 0xFF)
        let digest2: Byte =   Byte((a0 >> 16) & 0xFF)
        let digest3: Byte =   Byte((a0 >> 24) & 0xFF)

        let digest4: Byte =   Byte((b0 >> 0) & 0xFF)
        let digest5: Byte =   Byte((b0 >> 8) & 0xFF)
        let digest6: Byte =   Byte((b0 >> 16) & 0xFF)
        let digest7: Byte =   Byte((b0 >> 24) & 0xFF)

        let digest8: Byte =   Byte((c0 >> 0) & 0xFF)
        let digest9: Byte =   Byte((c0 >> 8) & 0xFF)
        let digest10: Byte =  Byte((c0 >> 16) & 0xFF)
        let digest11: Byte =  Byte((c0 >> 24) & 0xFF)
        
        let digest12: Byte =  Byte((d0 >> 0) & 0xFF)
        let digest13: Byte =  Byte((d0 >> 8) & 0xFF)
        let digest14: Byte =  Byte((d0 >> 16) & 0xFF)
        let digest15: Byte =  Byte((d0 >> 24) & 0xFF)
        
        let digest = [
            digest0, digest1, digest2,  digest3,  digest4,  digest5,  digest6,  digest7,
            digest8, digest9, digest10, digest11, digest12, digest13, digest14, digest15,
        ]
        
        assert(digest.count == 16)
        
        return digest
    }
}

extension String {

    var md5: String {
        let bytes = Array<MD5.Byte>(self.utf8)
        let encodedBytes = MD5.calculate(bytes)

        let string = encodedBytes.reduce("") { string, byte in
            let radix = 16
            let hex = String(byte, radix: radix)
            let sum = string + (byte < MD5.Byte(radix) ? "0" : "") + hex
            return sum
        }

        return string
    }

}
