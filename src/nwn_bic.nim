# some include like neverwinter and os
import neverwinter/gff
import os, strutils, streams

# define help or failure msg whilst using
let c = paramCount()
if c == 0:
  echo """Extracts the way you or someone leveled up the given
toon and prints it in a readable way to a text file.
Usage:
  nwn_bic <bic>
"""

# get cmd params
let args = paramStr(1) # commandLineParams()

let root = openFileStream(args).readGffRoot(true)

echo root["Str", byte]
let input = root["Str", byte]

var output = newFileStream("default.txt", fmWrite)
if not isNil(output):
  output.writeLine(input)
  output.close()


