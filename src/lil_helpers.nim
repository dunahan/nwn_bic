# get classname by int
proc Classes(num: int): string =
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
