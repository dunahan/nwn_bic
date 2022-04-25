# Package
version       = "0.1.1"
author        = "dunahan"
description   = "nwn_bic prints lvlup structure of nwn toons"
license       = "MIT"
srcDir        = "src"
bin           = @["nwn_bic"]


# Dependencies
requires "nim >= 1.6.4"
requires "neverwinter >= 1.4.2"

task win, "Cross compile windows binary with mingw":
  echo "Building windows binary with mingw"
  let file = bin[0]
  exec "nimble build -d:mingw -d:release --passL:-static --dynlibOverrideAll " & file

task macos, "Build macOS binary with sqlite3 statically linked":
  echo "Building macOS binary"
  let file = bin[0]
  exec "nimble build -d:release " & file
