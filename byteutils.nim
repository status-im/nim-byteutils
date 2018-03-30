# byteutils
# Copyright (c) 2018 Status Research & Development GmbH
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.


########################################################################################################
####################################   Array utilities   ###############################################

import algorithm

proc initArrayWith*[N: static[int], T](value: T): array[N, T] {.noInit,inline, noSideEffect.}=
  result.fill(value)

proc `&`*[N1, N2: static[int], T](
    a: array[N1, T],
    b: array[N2, T]
    ): array[N1 + N2, T] {.noSideEffect, inline, noInit.}=
  ## Array concatenation
  result[0 ..< N1] = a
  result[N1 ..< N2] = b


########################################################################################################
#####################################   Hex utilities   ################################################

proc readHexChar*(c: char): byte {.noSideEffect, inline.}=
  ## Converts an hex char to a byte
  case c
  of '0'..'9': result = byte(ord(c) - ord('0'))
  of 'a'..'f': result = byte(ord(c) - ord('a') + 10)
  of 'A'..'F': result = byte(ord(c) - ord('A') + 10)
  else:
    raise newException(ValueError, $c & "is not a hexademical character")

proc skip0xPrefix(hexStr: string): int {.noSideEffect, inline.} =
  ## Returns the index of the first meaningful char in `hexStr` by skipping
  ## "0x" prefix
  if hexStr[0] == '0' and hexStr[1] in {'x', 'X'}:
    result = 2

proc hexToByteArrayBE*(hexStr: string, output: var openArray[byte], fromIdx, toIdx: int) {.noSideEffect.}=
  ## Read a hex string and store it in a Byte Array `output` in Big-Endian order
  var i = skip0xPrefix(hexStr)

  assert(fromIdx >= 0 and toIdx >= fromIdx and fromIdx < output.len and toIdx < output.len)
  let sz = toIdx - fromIdx + 1

  assert hexStr.len - i == 2*sz

  while i < sz:
    output[fromIdx + i] = hexStr[2*i].readHexChar shl 4 or hexStr[2*i+1].readHexChar
    inc(i)

proc hexToByteArrayBE*(hexStr: string, output: var openArray[byte]) {.inline, noSideEffect.} =
  ## Read a hex string and store it in a Byte Array `output` in Big-Endian order
  hexToByteArrayBE(hexStr, output, 0, output.high)

proc hexToByteArrayBE*[N: static[int]](hexStr: string): array[N, byte] {.noSideEffect, noInit, inline.}=
  ## Read an hex string and store it in a Byte Array in Big-Endian order
  hexToByteArrayBE(hexStr, result)

proc hexToSeqByteBE*(hexStr: string): seq[byte] {.noSideEffect.}=
  ## Read an hex string and store it in a sequence of bytes in Big-Endian order
  var i = skip0xPrefix(hexStr)

  let N = (hexStr.len - i) div 2

  result = newSeq[byte](N)
  while i < N:
    result[i] = hexStr[2*i].readHexChar shl 4 or hexStr[2*i+1].readHexChar
    inc(i)

proc toHexAux(ba: openarray[byte]): string {.noSideEffect.} =
  ## Convert a byte-array to its hex representation
  ## Output is in lowercase
  const hexChars = "0123456789abcdef"

  let sz = ba.len
  result = newString(2 * sz)
  for i in 0 ..< sz:
    result[2*i] = hexChars[int ba[i] shr 4 and 0xF]
    result[2*i+1] = hexChars[int ba[i] and 0xF]


proc toHex*(ba: openarray[byte]): string {.noSideEffect, inline.} =
  ## Convert a big endian byte-array to its hex representation
  ## Output is in lowercase
  toHexAux(ba)

proc toHex*[N: static[int]](ba: array[N, byte]): string {.noSideEffect, inline.} =
  ## Convert a big endian byte-array to its hex representation
  ## Output is in lowercase
  toHexAux(ba)
