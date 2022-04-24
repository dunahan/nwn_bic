# some includes like neverwinter/gff, std/os, strutils, streams
import neverwinter/gff
import os, strutils, streams
import helper

# declare constants
const LINE = "-----------------------"

# define help or failure msg whilst using
if paramCount() == 0:
  quit("""Extracts the way you or someone leveled up the given
toon and prints it in a readable way to a text file.
Usage:
  nwn_bic <test.bic>
""")

# get cmd params
let args = paramStr(1)
if args  == "":
  quit("""Given file not found.
Usage:
  nwn_bic <test.bic>
""")

let root = openFileStream(args).readGffRoot(false)
var (dir, name, ext) = splitFile(args)
var output = newFileStream(name & ".txt", fmWrite)

if not isNil(output):
  output.writeLine(LINE, "\n     IDENTITY\n", LINE)
  
  var start = 0
  var first = $root["FirstName", GffCExoLocString]
  delete(first, start..find(first, '"'))
  delete(first, find(first, '"')..find(first, '}'))
  
  # how to do this in a new func?
  var last = $root["LastName", GffCExoLocString]
  delete(last, start..find(last, '"'))
  delete(last, find(last, '"')..find(last, '}'))
  output.writeLine("Name: " & first & " " & last & "\n" &
    "Race: " & bicRace(root["Race", byte]) & "\n" &
    "Gender: " & bicGender(root["Gender", byte]) & "\n" &
    "Age: " & $root["Age", 0.GffInt])

  var description = $root["Description", GffCExoLocString]
  delete(description, start..find(description, '"'))
  delete(description, find(description, '"')..find(description, '}'))

  output.writeLine("Description: " & description & "\n" &
    "Subrace: " & $root["Subrace", GFFCExoString] & "\n" &
    "Deity: " & $root["Deity", GFFCExoString] & "\n" &
    "\n", LINE, "\n     FINAL BUILD\n", LINE & "\n" &
    "\nCLASSES:")
    
  var clist = root["ClassList", GffList]
  var nbrc = count($clist, "GffStruct")
  
  var i, c: int
  for i in countup(1, nbrc):
    c = i - 1
    output.writeLine(" - " & bicClass(clist[c]["Class", GffInt]) & " (" &
      $clist[c]["ClassLevel", c.GffShort] & ")")
#   "School: " & $clist[c]["School", byte])
  
  output.writeLine("\nABILITIES:" & "\n" &
    "  Str: " & $root["Str", byte] & "\n" &
    "  Dex: " & $root["Dex", byte] & "\n" &
    "  Con: " & $root["Con", byte] & "\n" &
    "  Int: " & $root["Int", byte] & "\n" &
    "  Wis: " & $root["Wis", byte] & "\n" &
    "  Cha: " & $root["Cha", byte])
  
  output.writeLine("\nSTATISTICS:" & "\n" &
    "  Aligment: " & bicAlignmLC(root["LawfulChaotic", byte]) & " " &
    bicAlignmGE(root["GoodEvil", byte]))
  output.writeLine("  Experience: " & $root["Experience", 0.GffDWord] & "\n" &
    "  Hit Points: " & $root["MaxHitPoints", 0.GffShort])
# output.writeLine("  Num. Attacks: " & $root["NumAttacks", byte]) # is in gff, but not accessible?
  output.writeLine("  Base Att. Bonus: " & $root["BaseAttackBonus", byte] & "\n" &
    "  Nat. AC/Act. AC: " & $root["NaturalAC", byte] & " / " &
    $root["ArmorClass", 0.GffShort])  # works for 1.69 but not for EE?
  output.writeLine("  Will Save/Bonus: " & $root["WillSaveThrow", 0.GffChar] & " / " &
    $root["willbonus", 0.GffShort] & "\n" &
    "  Fort. Save/Bonus: " & $root["FortSaveThrow", 0.GffChar] & " / " &
    $root["fortbonus", 0.GffShort] & "\n" &
    "  Ref. Save/Bonus: " & $root["RefSaveThrow", 0.GffChar] & " / " &
    $root["refbonus", 0.GffShort])
  
  output.writeLine("\nSKILLS:")
  var slist = root["SkillList", GffList]
  var nbrs = count($slist, "GffStruct")
  i = 0
  c = 0
  for i in countup(1, nbrs):
    c = i - 1
    output.writeLine(" - " & bicSkill(c) & ": ")
  
  output.writeLine("\nFEATS:")
  var flist = root["FeatList", GffList]
  var nbrf = count($flist, "GffStruct")
  i = 0
  c = 0
  for i in countup(1, nbrf):
    c = i - 1
    output.writeLine(" - " & bicFeat(c))
  
  output.writeLine("\n\n\n" & LINE, "\n     BUILD DETAILS\n", LINE)
  output.writeLine("working on this section")
  
  output.close()

