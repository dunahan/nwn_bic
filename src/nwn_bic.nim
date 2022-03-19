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
var output = newFileStream("default.txt", fmWrite)
if not isNil(output):
  output.writeLine("\n", LINE, "\n     IDENTITY\n", LINE)
  output.writeLine("Name: " & $root["FirstName", GffCExoLocString] & " " &
    $root["LastName", GffCExoLocString]) #substr!
  output.writeLine("Race: " & $root["Race", byte])
  output.writeLine("Gender: " & $root["Gender", byte])
  output.writeLine("Age: " & $root["Age", 0.GffInt])
  output.writeLine("Description: " & $root["Description", GffCExoLocString])
  output.writeLine("Subrace: " & $root["Subrace", GFFCExoString])
  output.writeLine("Deity: " & $root["Deity", GFFCExoString])
  output.writeLine("\n", LINE, "\n     FINAL BUILD\n", LINE)
  
  output.writeLine("\nCLASSES:")
  # loop for classes in list and output them, classtype to determinate by 2da?
  
  output.writeLine("\nABILITIES:")
  output.writeLine("  Str: " & $root["Str", byte])
  output.writeLine("  Dex: " & $root["Dex", byte])
  output.writeLine("  Con: " & $root["Con", byte])
  output.writeLine("  Int: " & $root["Int", byte])
  output.writeLine("  Wis: " & $root["Wis", byte])
  output.writeLine("  Cha: " & $root["Cha", byte])
  
  output.writeLine("\nSTATISTICS:")
  output.writeLine("  Aligment: " & $root["LawfulChaotic", byte] & " / " & $root["GoodEvil", byte])
  output.writeLine("  Experience: " & $root["Experience", 0.GffWord])
  output.writeLine("  Hit Points: " & $root["MaxHitPoints", 0.GffShort])
  #output.writeLine("  Num. Attacks: " & $root["NumAttacks", byte])
  output.writeLine("  Base Att. Bonus: " & $root["BaseAttackBonus", byte])
  output.writeLine("  Nat. AC/Act. AC: " & $root["NaturalAC", byte] & " / " & $root["ArmorClass", 0.GffShort])
  output.writeLine("  Will Save/Bonus: " & $root["WillSaveThrow", 0.GffChar] & " / " & $root["willbonus", 0.GffShort])
  output.writeLine("  Fort. Save/Bonus: " & $root["FortSaveThrow", 0.GffChar] & " / " & $root["fortbonus", 0.GffShort])
  output.writeLine("  Ref. Save/Bonus: " & $root["RefSaveThrow", 0.GffChar] & " / " & $root["refbonus", 0.GffShort])
  
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
