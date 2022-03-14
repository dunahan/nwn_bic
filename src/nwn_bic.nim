# some includes like neverwinter/gff, std/os, strutils, streams
import neverwinter/gff
import os, strutils, streams

# declare constants
const LINE = "-----------------------"

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
var input # = "Description: "
var data  # = root["Description", GffCExoLocString]

var output = newFileStream("default.txt", fmWrite)
if not isNil(output):
  output.writeLine(LINE)
  output.writeLine("     IDENTITY")
  output.writeLine(LINE)
  
  if not isEmptyOrWhitespace(root["FirstName", GffCExoLocString]):
    data = root["FirstName", GffCExoLocString], " ", root["LastName", GffCExoLocString]
  output.writeLine("Name: ", data)
  
  output.writeLine("Race: ")
  output.writeLine("Gender: ")
  output.writeLine("Age: ")
  output.writeLine("Description: ")
  output.writeLine("Subrace: ")
  output.writeLine("Deity: ")
  
  output.writeLine("\n", LINE)
  output.writeLine("     FINAL BUILD")
  output.writeLine(LINE)
  
  output.writeLine("\nCLASSES:")
  # loop for classes in list and output them, classtype to determinate by 2da?
  
  output.writeLine("\nABILITIES:")
  output.writeLine("  Str: ")
  output.writeLine("  Dex: ")
  output.writeLine("  Con: ")
  output.writeLine("  Int: ")
  output.writeLine("  Wis: ")
  output.writeLine("  Cha: ")
  
  output.writeLine("\nSTATISTICS:")
  output.writeLine("  Hit Points: ")
  output.writeLine("  AC: ")
  output.writeLine("  Will Save: ")
  output.writeLine("  Fort. Save: ")
  output.writeLine("  Ref. Save: ")
  
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
