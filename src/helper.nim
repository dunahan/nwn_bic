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


# get Alignment Lawful/Chaotic
proc bicAlignmLC*(num: byte): string =
  result = case num:
   of 70..100:
     "Lawful"
   of 31..69:
     "Neutral"
   of 0..30:
     "Chaotic"
   else:
     ""


# get Alignment Good/Evil
proc bicAlignmGE*(num: byte): string =
  result = case num:
   of 70..100:
     "Good"
   of 31..69:
     "Neutral"
   of 0..30:
     "Evil"
   else:
     ""

# get skill
proc bicSkill*(num: int): string =
  result = case num:
    of 0:
      "Animal Empathy"
    of 1:
      "Concentration"
    of 2:
      "DisableTrap"
    of 3:
      "Discipline"
    of 4:
      "Heal"
    of 5:
      "Hide"
    of 6:
      "Listen"
    of 7:
      "Lore"
    of 8:
      "MoveSilently"
    of 9:
      "OpenLock"
    of 10:
      "Parry"
    of 11:
      "Perform"
    of 12:
      "Persuade"
    of 13:
      "Pick Pocket"
    of 14:
      "Search"
    of 15:
      "Set Trap"
    of 16:
      "Spellcraft"
    of 17:
      "Spot"
    of 18:
      "Taunt"
    of 19:
      "Use Magic Device"
    of 20:
      "Appraise"
    of 21:
      "Tumble"
    of 22:
      "Craft Trap"
    of 23:
      "Bluff"
    of 24:
      "Intimidate"
    of 25:
      "Craft Armor"
    of 26:
      "Craft Weapon"
    else:
      "Unknown"


# write line only if it has something with value?


#[ cut down LocStrings
proc bicCutLocString*(s: string): string =
  var start = 0
  delete(s, start..find(s, '"'))
  delete(s, find(s, '"')..find(s, '}'))
  result s ]#