#get race by int
proc bicRace*(num: byte): string =
  result = case num:
    of 0:
      "Dwarf"
    of 1:
      "Elf"
    of 2:
      "Gnome"
    of 3:
      "Halfling"
    of 4:
      "Half Elf"
    of 5:
      "Half Orc"
    of 6:
      "Human"
    of 7:
      "Aberration"
    of 8:
      "Animal"
    of 9:
      "Beast"
    of 10:
      "Construct"
    of 11:
      "Dragon"
    of 12:
      "Goblinoid"
    of 13:
      "Monstrous"
    of 14:
      "Orc"
    of 15:
      "Reptilian"
    of 16:
      "Elemental"
    of 17:
      "Fey"
    of 18:
      "Giant"
    of 19:
      "Magical Beast"
    of 20:
      "Outsider"
    of 23:
      "Shapechanger"
    of 24:
      "Undead"
    of 25:
      "Vermin"
    of 29:
      "Ooze"
    else:
      "Unknown"

#get gender by int
proc bicGender*(num: byte): string =
  result = case num:
    of 0:
      "Male"
    of 1:
      "Female"
    else:
      "Unknown"

# get classname by int
proc bicClass*(num: int): string =
  result = case num:
    of 0:
      "Barbarian"
    of 1:
      "Bard"
    of 2:
      "Cleric"
    of 3:
      "Druid"
    of 4:
      "Fighter"
    of 5:
      "Monk"
    of 6:
      "Paladin"
    of 7:
      "Ranger"
    of 8:
      "Rogue"
    of 9:
      "Sorcerer"
    of 10:
      "Wizard"
    of 27:
      "Shadowdancer"
    of 28:
      "Harper"
    of 29:
      "Arcane Archer"
    of 30:
      "Assassin"
    of 31:
      "Blackguard"
    of 32:
      "Champion of Torm"
    of 33:
      "Weapon Master"
    of 34:
      "Pale Master"
    of 35:
      "Shifter"
    of 36:
      "Dwarven Defender"
    of 37:
      "Dragon Disciple"
    of 41:
      "Purple Dragon Knight"
    else:
      "Unknown"

#proc bicAlignmRC*


#proc bicAlignmGE*


#[ cut down LocStrings
proc bicCutLocString*(s: string): string =
  var start = 0
  delete(s, start..find(s, '"'))
  delete(s, find(s, '"')..find(s, '}'))
  result s ]#