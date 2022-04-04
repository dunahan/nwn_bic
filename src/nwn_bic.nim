# some includes like neverwinter/gff, std/os, strutils, streams
import neverwinter/gff
import os, strutils, streams
import lil_helpers

# declare constants
const LINE = "-----------------------"

# define help or failure msg whilst using
if paramCount() == 0:
  quit("""Ext racts the way you or someone leveled up the given
toon and prints it in a readable way to a text file.
Usage:
  nwn_bic <bic>
""")

# get cmd params
let args = paramStr(1)
let root = openFileStream(args).readGffRoot(false)
var (dir, name, ext)= splitFile(args)
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
  output.writeLine("Name: " & first & " " & last)

  output.writeLine("Race: " & $root["Race", byte])
  output.writeLine("Gender: " & $root["Gender", byte])
  output.writeLine("Age: " & $root["Age", 0.GffInt])

  var description = $root["Description", GffCExoLocString]
  delete(description, start..find(description, '"'))
  delete(description, find(description, '"')..find(description, '}'))

  output.writeLine("Description: " & description)
  output.writeLine("Subrace: " & $root["Subrace", GFFCExoString])
  output.writeLine("Deity: " & $root["Deity", GFFCExoString])
  output.writeLine("\n", LINE, "\n     FINAL BUILD\n", LINE)
  
  output.writeLine("\nCLASSES:")
  var clist = root["ClassList", GffList]
  var cls1 = -1
  var cls2 = -1
  var cls3 = -1
  
  cls1 = clist[0]["Class", GffInt]
  if cls1 >= 0:
    output.writeLine("class/lvl: " & $cls1 & " (" &
      $clist[0]["ClassLevel", 0.GffShort] & ")")
#   output.writeLine("schol nr1: " & $clist[0]["School", byte])
  
#[ cls2 = clist[1]["Class", GffInt]
  if cls2 >= 0:
    output.writeLine("class nr2: " & $cls2)
    output.writeLine("level nr2: " & $clist[1]["ClassLevel", 0.GffShort])
#   output.writeLine("schol nr2: " & $clist[1]["School", byte])
  
  cls3 = clist[2]["Class", GffInt]
  if cls3 >= 0:
    output.writeLine("class nr3: " & $cls3)
    output.writeLine("level nr3: " & $clist[2]["ClassLevel", 0.GffShort])
#   output.writeLine("schol nr3: " & $clist[2]["School", byte])
]#
  # loop for classes in list and output them, classtype to determinate by 2da?
  
  output.writeLine("\nABILITIES:")
  output.writeLine("  Str: " & $root["Str", byte])
  output.writeLine("  Dex: " & $root["Dex", byte])
  output.writeLine("  Con: " & $root["Con", byte])
  output.writeLine("  Int: " & $root["Int", byte])
  output.writeLine("  Wis: " & $root["Wis", byte])
  output.writeLine("  Cha: " & $root["Cha", byte])
  
  output.writeLine("\nSTATISTICS:")
  output.writeLine("  Aligment: " & $root["LawfulChaotic", byte] & " / " &
    $root["GoodEvil", byte])
  output.writeLine("  Experience: " & $root["Experience", 0.GffDWord])
  output.writeLine("  Hit Points: " & $root["MaxHitPoints", 0.GffShort])
# output.writeLine("  Num. Attacks: " & $root["NumAttacks", byte])
  output.writeLine("  Base Att. Bonus: " & $root["BaseAttackBonus", byte])
# output.writeLine("  Nat. AC/Act. AC: " & $root["NaturalAC", byte] & " / " &
#   $root["ArmorClass", 0.GffShort])  # works for 1.69 but not for EE?
  output.writeLine("  Armor Class: " & $root["ArmorClass", 0.GffShort])
  output.writeLine("  Will Save/Bonus: " & $root["WillSaveThrow", 0.GffChar] & " / " &
    $root["willbonus", 0.GffShort])
  output.writeLine("  Fort. Save/Bonus: " & $root["FortSaveThrow", 0.GffChar] & " / " &
    $root["fortbonus", 0.GffShort])
  output.writeLine("  Ref. Save/Bonus: " & $root["RefSaveThrow", 0.GffChar] & " / " &
    $root["refbonus", 0.GffShort])
  
  output.writeLine("\nSKILLS:")
  
  output.writeLine("\nFEATS:")
  
  output.writeLine(LINE)
  
  output.close()


#[
-----------------------
     IDENTITY
-----------------------

Name: FirstName, LastName [GffCExoLocString]
Race: Race [byte] > case switch? 2da readout?
Gender: Gender [byte] > case switch?
Age: Age [int]
Description: Description [GffCExoLocString]
Subrace: Subrace [GFFCExoString]
Deity: Deity [GFFCExoString]

-----------------------
     FINAL BUILD
-----------------------

CLASSES: >> ClassList [list]
 - Class [int] >> case switch? 2da readout? + (ClassLevel [short]) >> Barbarian (1) or
 - Magier (1), School: Allgemein

ABILITIES:
  Str: Str [byte]
  Dex: Dex [byte]
  Con: Con [byte]
  Int: Int [byte]
  Wis: Wis [byte]
  Cha: Cha [byte]

STATISTICS:
  Hit Points: MaxHitPoints [short]
  AC: ArmorClass [short]
  Will Save: WillSaveThrow [char] + willbonus [short]
  Fort. Save: FortSaveThrow [char] + fortbonus [short]
  Ref. Save: RefSaveThrow [char] + refbonus [short]

SKILLS: >> SkillList [list] ? >> pre-defined and choosen if > 0?
 - Konzentration: Rank [byte] >>  1
 - Sagenkunde: Rank [byte]    >>  7
 - Leise bewegen: Rank [byte] >>  8
 - Zauberkunde: Rank [byte]   >> 16
 - Entdecken: Rank [byte]     >> 17
]#
