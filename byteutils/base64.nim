#
#
#            Nim's Runtime Library
#        (c) Copyright 2010 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

# Code is MIT License modified by Status for arrays and sequence of bytes
# https://github.com/nim-lang/Nim/blob/72e15ff739cc73fbf6e3090756d3f9cb3d5af2fa/lib/pure/base64.nim#L125

const
  cb64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

template encodeInternal(s: typed, lineLen: int, newLine: string): untyped =
  ## encodes `s` into base64 representation. After `lineLen` characters, a
  ## `newline` is added.
  var total = ((len(s) + 2) div 3) * 4
  let numLines = (total + lineLen - 1) div lineLen
  if numLines > 0: inc(total, (numLines - 1) * newLine.len)

  result = newString(total)
  var
    i = 0
    r = 0
    currLine = 0
  while i < s.len - 2:
    let
      a = ord(s[i])
      b = ord(s[i+1])
      c = ord(s[i+2])
    result[r] = cb64[a shr 2]
    result[r+1] = cb64[((a and 3) shl 4) or ((b and 0xF0) shr 4)]
    result[r+2] = cb64[((b and 0x0F) shl 2) or ((c and 0xC0) shr 6)]
    result[r+3] = cb64[c and 0x3F]
    inc(r, 4)
    inc(i, 3)
    inc(currLine, 4)
    # avoid index out of bounds when lineLen == encoded length
    if currLine >= lineLen and i != s.len-2 and r < total:
      for x in items(newLine):
        result[r] = x
        inc(r)
      currLine = 0

  if i < s.len-1:
    let
      a = ord(s[i])
      b = ord(s[i+1])
    result[r] = cb64[a shr 2]
    result[r+1] = cb64[((a and 3) shl 4) or ((b and 0xF0) shr 4)]
    result[r+2] = cb64[((b and 0x0F) shl 2)]
    result[r+3] = '='
    if r+4 != result.len:
      setLen(result, r+4)
  elif i < s.len:
    let a = ord(s[i])
    result[r] = cb64[a shr 2]
    result[r+1] = cb64[(a and 3) shl 4]
    result[r+2] = '='
    result[r+3] = '='
    if r+4 != result.len:
      setLen(result, r+4)
  else:
    if r != result.len:
      setLen(result, r)
    #assert(r == result.len)
    discard

func toBase64*(s: openarray[byte], lineLen = 75, newLine="\13\10"): string =
  ## encodes `s` into base64 representation. After `lineLen` characters, a
  ## `newline` is added.
  ##
  ## This procedure encodes an openarray (array or sequence) of either integers
  ## or characters.
  encodeInternal(s, lineLen, newLine)

func decodeByte(b: char): byte {.inline.} =
  case b
  of '+': result = byte('>')
  of '0'..'9': result = byte(b) + 4
  of 'A'..'Z': result = byte(b) - byte('A')
  of 'a'..'z': result = byte(b) - 71
  else: result = 63

func base64toSeqByte*(s: string): seq[byte] =
  ## decodes a string in base64 representation back into its original form.
  ## Whitespace is skipped.
  const Whitespace = {' ', '\t', '\v', '\r', '\l', '\f'}
  var total = ((len(s) + 3) div 4) * 3
  # total is an upper bound, as we will skip arbitrary whitespace:
  result = newSeqUninitialized[byte](total)

  var
    i = 0
    r = 0
  while true:
    while i < s.len and s[i] in Whitespace: inc(i)
    if i < s.len-3:
      let
        a = s[i].decodeByte
        b = s[i+1].decodeByte
        c = s[i+2].decodeByte
        d = s[i+3].decodeByte

      result[r] = (a shl 2) and 0xff or ((b shr 4) and 0x03)
      result[r+1] = (b shl 4) and 0xff or ((c shr 2) and 0x0F)
      result[r+2] = (c shl 6) and 0xff or (d and 0x3F)
      inc(r, 3)
      inc(i, 4)
    else: break
  assert i == s.len
  # adjust the length:
  if i > 0 and s[i-1] == '=':
    dec(r)
    if i > 1 and s[i-2] == '=': dec(r)
  setLen(result, r)
