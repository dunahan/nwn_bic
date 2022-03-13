# some include like neverwinter and os
import neverwinter/gff
import os, strutils, streams

# define help or failure msg whilst using
if paramCount() == 0:
  quit("""Extracts the way you or someone leveled up the given
toon and prints it in a readable way to a text file.
Usage:
  nwn_bic <bic>
""")

# get cmd params
let args = paramStr(1)

let root = openFileStream(args).readGffRoot(false)
var input = "Description: "
var data = root["Description", GffCExoLocString]

var output = newFileStream("default.txt", fmWrite)
if not isNil(output):
  output.writeLine("----")
  output.writeLine(input, data)
  output.writeLine("----")
  output.close()


