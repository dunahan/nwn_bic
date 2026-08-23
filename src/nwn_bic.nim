# some includes like neverwinter/gff, std/os, strutils, streams
import neverwinter/gff
import os, strutils, streams, tables
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
# if no arg is given, quit with failure msg
if args == "":
  quit("""Given file not found.
Usage:
  nwn_bic <test.bic>
""")

# now contine
let root =
  try:
    openFileStream(args).readGffRoot(false)
  except CatchableError as e:
    quit("Error: could not read '" & args & "' as a GFF/BIC file (" & e.msg & ")")
var (dir, name, ext) = splitFile(args)
# ponytail: dir was unused before -- output landed in cwd instead of beside the input .bic
let outPath = dir / (name & ".txt")
var output = newFileStream(outPath, fmWrite)

# if the file is created, then begin with writing down
if not isNil(output):
  output.writeLine(LINE, "\n     IDENTITY\n", LINE) # first line
  
  # begin with first name
  var start = 0
  var first = $root["FirstName", GffCExoLocString]
  delete(first, start..find(first, '"'))
  delete(first, find(first, '"')..find(first, '}'))

  # get the last name
  var last = $root["LastName", GffCExoLocString]
  delete(last, start..find(last, '"'))
  delete(last, find(last, '"')..find(last, '}'))

  # now print those, contine with race, gender and age
  output.writeLine("Name: " & first & " " & last & "\n" &
    "Race: " & bicRace(root["Race", byte]) & "\n" &
    "Gender: " & bicGender(root["Gender", byte]) & "\n" &
    "Age: " & $root["Age", 0.GffInt])

  # now we need to get the description cutted right
  var description = $root["Description", GffCExoLocString]
  delete(description, start..find(description, '"'))
  delete(description, find(description, '"')..find(description, '}'))

  # and print it along with subrace, deity and finally the next topics
  output.writeLine("Description: " & description & "\n" &
    "Subrace: " & $root["Subrace", GFFCExoString] & "\n" &
    "Deity: " & $root["Deity", GFFCExoString] & "\n" &
    "\n", LINE, "\n     FINAL BUILD\n", LINE & "\n" &
    "\nCLASSES:")

  # time to build up the classes
  var clist = root["ClassList", GffList]
  var nbrc = count($clist, "GffStruct") # how many classes could be hiding?
  var i, c: int
  for i in countup(1, nbrc): # using a for loop fot the classes
    c = i - 1
    let school = clist[c]["School", 255.GffByte]
    let schoolSuffix = if school.byte != 255: ", School: " & bicSchool(
        school.byte) else: ""
    output.writeLine(" - " & bicClass(clist[c]["Class", GffInt]) & " (" &
      $clist[c]["ClassLevel", c.GffShort] & ")" & schoolSuffix)

  # print those final abilities
  output.writeLine("\nABILITIES:" & "\n" &
    "  Str: " & $root["Str", byte] & "\n" &
    "  Dex: " & $root["Dex", byte] & "\n" &
    "  Con: " & $root["Con", byte] & "\n" &
    "  Int: " & $root["Int", byte] & "\n" &
    "  Wis: " & $root["Wis", byte] & "\n" &
    "  Cha: " & $root["Cha", byte])

  # and stats, like aligment, experience, hit points, base attack, armor class and saves
  output.writeLine("\nSTATISTICS:" & "\n" &
    "  Aligment: " & bicAlignmLC(root["LawfulChaotic", byte]) & " " &
    bicAlignmGE(root["GoodEvil", byte]))
  output.writeLine("  Experience: " & $root["Experience", 0.GffDWord] & "\n" &
    "  Hit Points: " & $root["MaxHitPoints", 0.GffShort])
# output.writeLine("  Num. Attacks: " & $root["NumAttacks", byte])  # is in gff, but not accessible?
  output.writeLine("  Base Att. Bonus: " & $root["BaseAttackBonus", 0.GffByte] & "\n" &
    "  Nat. AC/Act. AC: " & # $root["NaturalAC", byte] & " / " & # commented out until a solution is possible
    $root["ArmorClass", 0.GffShort]) # works for 1.69 but not for EE?
  output.writeLine("  Will Save/Bonus: " & $root["WillSaveThrow", 0.GffChar] & " / " &
    $root["willbonus", 0.GffShort] & "\n" &
    "  Fort. Save/Bonus: " & $root["FortSaveThrow", 0.GffChar] & " / " &
    $root["fortbonus", 0.GffShort] & "\n" &
    "  Ref. Save/Bonus: " & $root["RefSaveThrow", 0.GffChar] & " / " &
    $root["refbonus", 0.GffShort])

  # skills: list position is the skill ID (matches skills.2da / bicSkill order); print only Rank > 0, matching the reference tool
  output.writeLine("\nSKILLS:")
  # ponytail: 1.69 skill table only (27 entries); EE adds more, add when EE support lands.
  var slist = root["SkillList", GffList]
  var nbrs = count($slist, "GffStruct")
  i = 0
  c = 0
  for i in countup(1, nbrs):
    c = i - 1
    let rank = slist[c]["Rank", byte]
    if rank > 0:
      output.writeLine(" - " & bicSkill(c) & ": " & $rank)

  # feats: unlike SkillList, each FeatList struct carries its own ID in a "Feat" field -- list position is just insertion order
  output.writeLine("\nFEATS:")
  # ponytail: GffWord (uint16) doesn't implicitly convert to int like GffInt does, hence the .int below
  var flist = root["FeatList", GffList]
  var nbrf = count($flist, "GffStruct")
  let charRace = root["Race", byte].int
  i = 0
  c = 0
  for i in countup(1, nbrf):
    c = i - 1
    let featId = flist[c]["Feat", GffWord].int
    var origin = ""
    if bicIsRaceFeat(charRace, featId):
      origin = "(RACE) "
    else:
      for cc in 0..<nbrc:
        if bicIsClassFeat(clist[cc]["Class", GffInt], featId):
          origin = "(CLASS) "
          break
    output.writeLine(" - " & origin & bicFeat(featId))

  # those section should later show the build process per taken level
  output.writeLine("\n\n\n" & LINE, "\n     BUILD DETAILS\n", LINE)

  let mods = bicRaceAbilityMods(root["Race", byte])
  let finals = [root["Str", byte].int, root["Dex", byte].int, root["Con", byte].int,
                root["Int", byte].int, root["Wis", byte].int, root["Cha", byte].int]
  const abilNames = ["Str", "Dex", "Con", "Int", "Wis", "Cha"]
  output.writeLine("\nSTARTING ABILITIES:")
  for idx in 0..5:
    let base = 8 + mods[idx]
    let delta = finals[idx] - base
    let sign = if delta < 0: "-" else: "+"
    output.writeLine("  " & abilNames[idx] & ": " & $finals[idx] & " (base " &
      intToStr(base, 2) & sign & intToStr(abs(delta), 2) & ")")

  # level-by-level build history: LvlStatList[i] = character level i+1; LvlStatClass
  # tracks the real class ID even across multiclass level-ups (verified: palemas169.bic)
  var lvlList = root["LvlStatList", GffList]
  var nbrl = count($lvlList, "GffStruct")
  for lvlIdx in 0..<nbrl:
    let lvlEntry = lvlList[lvlIdx]
    let lvlClass = lvlEntry["LvlStatClass", byte].int
    output.writeLine("\n" & LINE)
    output.writeLine("Level " & $(lvlIdx + 1) & " - " & bicClass(lvlClass))
    output.writeLine("Hitpoint dice: " & $lvlEntry["LvlStatHitDie", byte])
    let abilInc = lvlEntry["LvlStatAbility", 255.GffByte]
    if abilInc.byte != 255:
      output.writeLine("Ability: " & abilNames[abilInc.byte.int])
    # ponytail: reference tool prints "Skills: None" unconditionally, even where points were spent -- showing the real per-level ranks instead, the data is right there (verified additive on test2.bic).
    output.writeLine("Skills:")
    var lvlSkills = lvlEntry["SkillList", GffList]
    var nbrls = count($lvlSkills, "GffStruct")
    var anySkill = false
    for si in 0..<nbrls:
      let rank = lvlSkills[si]["Rank", byte]
      if rank > 0:
        output.writeLine(" - " & bicSkill(si) & ": " & $rank)
        anySkill = true
    if not anySkill:
      output.writeLine("None")

    output.writeLine("\nFeats:")
    var lvlFeats = lvlEntry["FeatList", GffList]
    var nbrlf = count($lvlFeats, "GffStruct")
    if nbrlf == 0:
      output.writeLine("None")
    for fi in 0..<nbrlf:
      let featId = lvlFeats[fi]["Feat", GffWord].int
      var origin = ""
      if bicIsRaceFeat(charRace, featId):
        origin = "(RACE) "
      elif bicIsClassFeat(lvlClass, featId):
        origin = "(CLASS) "
      output.writeLine(" - " & origin & bicFeat(featId))
    output.writeLine("")

  # finally were ready to close the file, due all is printed...
  output.close()
else:
  quit("Error: could not write output to '" & outPath & "'")
