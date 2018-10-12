# byteutils
# Copyright (c) 2018 Status Research & Development GmbH
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  unittest,
        ../byteutils

suite "Base64":
  let pwdBytes = hexToSeqByte"5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8"
  let pwdB64 = "XohImNooBHFR0OVvjcYpJ3NgPQ1qq73WKhHvch0VQtg="

  test "Encoding":
    block: # From https://crypto.stackexchange.com/questions/34995/why-do-we-use-hex-output-for-hash-functions
      # Hex representation of sha256 of "password"
      check: pwdBytes.toBase64 == pwdB64
  test "Decoding":
    block: # From https://crypto.stackexchange.com/questions/34995/why-do-we-use-hex-output-for-hash-functions
      # Hex representation of sha256 of "password"
      check: pwdBytes == pwdB64.base64toSeqByte
