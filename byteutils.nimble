packageName   = "byteutils"
version       = "0.0.1"
author        = "Status Research & Development GmbH"
description   = "A library to handle raw bytes and hex representations"
license       = "MIT or Apache License 2.0"
skipDirs      = @["tests"]

### Dependencies
requires "nim >= 0.18.0"

### Helper functions
proc test(name: string, defaultLang = "c") =
  # TODO, don't forget to change defaultLang to `cpp` if the project requires C++
  if not dirExists "build":
    mkDir "build"
  if not dirExists "nimcache":
    mkDir "nimcache"
  --run
  --nimcache:nimcache
  --threads:on
  switch("out", ("./build/" & name))
  setCommand defaultLang, "tests/" & name & ".nim"

### tasks
task test, "Run all tests":
  test "all_tests"
