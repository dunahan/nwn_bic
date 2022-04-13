# write line only if it has something with value?


#[ cut down LocStrings
proc bicCutLocString*(s: string): string =
  var start = 0
  delete(s, start..find(s, '"'))
  delete(s, find(s, '"')..find(s, '}'))
  result s ]#


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
      "Disable Trap"
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
      "Move Silently"
    of 9:
      "Open Lock"
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

proc bicFeat*(num: word): string =
  result = case num:
    of 0:
      "Alertness"
    of 1:
      "Ambidexterity"
    of 2:
      "Armor Proficiency (heavy)"
    of 3:
      "Armor Proficiency (light)"
    of 4:
      "Armor Proficiency (medium)"
    of 5:
      "Called Shot"
    of 6:
      "Cleave"
    of 7:
      "Combat Casting"
    of 8:
      "Deflect Arrows"
    of 9:
      "Disarm"
    of 10:
      "Dodge"
    of 11:
      "Empower Spell"
    of 12:
      "Extend Spell"
    of 13:
      "Extra Turning"
    of 14:
      "Great Fortitude"
    of 15:
      "Improved Critical (club)"
    of 16:
      "Improved Disarm"
    of 17:
      "Improved Knockdown"
    of 18:
      "Improved Parry"
    of 19:
      "Improved Power Attack"
    of 20:
      "Improved Two-Weapon Fighting"
    of 21:
      "Improved Unarmed Strike"
    of 22:
      "Iron Will"
    of 23:
      "Knockdown"
    of 24:
      "Lightning Reflexes"
    of 25:
      "Maximize Spell"
    of 26:
      "Mobility"
    of 27:
      "Point Blank Shot"
    of 28:
      "Power Attack"
    of 29:
      "Quicken Spell"
    of 30:
      "Rapid Shot"
    of 31:
      "Sap"
    of 32:
      "Shield Proficiency"
    of 33:
      "Silent Spell"
    of 34:
      "Skill Focus (Animal Empathy)"
    of 35:
      "Spell Focus (Abjuration)"
    of 36:
      "Spell Penetration"
    of 37:
      "Still Spell"
    of 39:
      "Stunning Fist"
    of 40:
      "Toughness"
    of 41:
      "Two-Weapon Fighting"
    of 42:
      "Weapon Finesse"
    of 43:
      "Weapon Focus (club)"
    of 44:
      "Weapon Proficiency (exotic)"
    of 45:
      "Weapon Proficiency (martial)"
    of 46:
      "Weapon Proficiency (simple)"
    of 47:
      "Weapon Specialization (club)"
    of 48:
      "Weapon Proficiency (druid)"
    of 49:
      "Weapon Proficiency (monk)"
    of 50:
      "Weapon Proficiency (rogue)"
    of 51:
      "Weapon Proficiency (wizard)"
    of 52:
      "Improved Critical (dagger)"
    of 53:
      "Improved Critical (dart)"
    of 54:
      "Improved Critical (heavy crossbow)"
    of 55:
      "Improved Critical (light crossbow)"
    of 56:
      "Improved Critical (mace)"
    of 57:
      "Improved Critical (morningstar)"
    of 58:
      "Improved Critical (quarterstaff)"
    of 59:
      "Improved Critical (spear)"
    of 60:
      "Improved Critical (sickle)"
    of 61:
      "Improved Critical (sling)"
    of 62:
      "Improved Critical (unarmed strike)"
    of 63:
      "Improved Critical (longbow)"
    of 64:
      "Improved Critical (shortbow)"
    of 65:
      "Improved Critical (short sword)"
    of 66:
      "Improved Critical (rapier)"
    of 67:
      "Improved Critical (scimitar)"
    of 68:
      "Improved Critical (longsword)"
    of 69:
      "Improved Critical (greatsword)"
    of 70:
      "Improved Critical (handaxe)"
    of 71:
      "Improved Critical (throwing axe)"
    of 72:
      "Improved Critical (battleaxe)"
    of 73:
      "Improved Critical (greataxe)"
    of 74:
      "Improved Critical (halberd)"
    of 75:
      "Improved Critical (light hammer)"
    of 76:
      "Improved Critical (light flail)"
    of 77:
      "Improved Critical (warhammer)"
    of 78:
      "Improved Critical (heavy flail)"
    of 79:
      "Improved Critical (kama)"
    of 80:
      "Improved Critical (kukri)"
    of 82:
      "Improved Critical (shuriken)"
    of 83:
      "Improved Critical (scythe)"
    of 84:
      "Improved Critical (katana)"
    of 85:
      "Improved Critical (bastard sword)"
    of 87:
      "Improved Critical (dire mace)"
    of 88:
      "Improved Critical (double axe)"
    of 89:
      "Improved Critical (two-bladed sword)"
    of 90:
      "Weapon Focus (dagger)"
    of 91:
      "Weapon Focus (dart)"
    of 92:
      "Weapon Focus (heavy crossbow)"
    of 93:
      "Weapon Focus (light crossbow)"
    of 94:
      "Weapon Focus (mace)"
    of 95:
      "Weapon Focus (morningstar)"
    of 96:
      "Weapon Focus (quarterstaff)"
    of 97:
      "Weapon Focus (spear)"
    of 98:
      "Weapon Focus (sickle)"
    of 99:
      "Weapon Focus (sling)"
    of 100:
      "Weapon Focus (unarmed strike)"
    of 101:
      "Weapon Focus (longbow)"
    of 102:
      "Weapon Focus (shortbow)"
    of 103:
      "Weapon Focus (short sword)"
    of 104:
      "Weapon Focus (rapier)"
    of 105:
      "Weapon Focus (scimitar)"
    of 106:
      "Weapon Focus (longsword)"
    of 107:
      "Weapon Focus (greatsword)"
    of 108:
      "Weapon Focus (handaxe)"
    of 109:
      "Weapon Focus (throwing axe)"
    of 110:
      "Weapon Focus (battleaxe)"
    of 111:
      "Weapon Focus (greataxe)"
    of 112:
      "Weapon Focus (halberd)"
    of 113:
      "Weapon Focus (light hammer)"
    of 114:
      "Weapon Focus (light flail)"
    of 115:
      "Weapon Focus (warhammer)"
    of 116:
      "Weapon Focus (heavy flail)"
    of 117:
      "Weapon Focus (kama)"
    of 118:
      "Weapon Focus (kukri)"
    of 120:
      "Weapon Focus (shuriken)"
    of 121:
      "Weapon Focus (scythe)"
    of 122:
      "Weapon Focus (katana)"
    of 123:
      "Weapon Focus (bastard sword)"
    of 125:
      "Weapon Focus (dire mace)"
    of 126:
      "Weapon Focus (double axe)"
    of 127:
      "Weapon Focus (two-bladed sword)"
    of 128:
      "Weapon Specialization (dagger)"
    of 129:
      "Weapon Specialization (dart)"
    of 130:
      "Weapon Specialization (heavy crossbow)"
    of 131:
      "Weapon Specialization (light crossbow)"
    of 132:
      "Weapon Specialization (mace)"
    of 133:
      "Weapon Specialization (morningstar)"
    of 134:
      "Weapon Specialization (quarterstaff)"
    of 135:
      "Weapon Specialization (spear)"
    of 136:
      "Weapon Specialization (sickle)"
    of 137:
      "Weapon Specialization (sling)"
    of 138:
      "Weapon Specialization (unarmed strike)"
    of 139:
      "Weapon Specialization (longbow)"
    of 140:
      "Weapon Specialization (shortbow)"
    of 141:
      "Weapon Specialization (short sword)"
    of 142:
      "Weapon Specialization (rapier)"
    of 143:
      "Weapon Specialization (scimitar)"
    of 144:
      "Weapon Specialization (longsword)"
    of 145:
      "Weapon Specialization (greatsword)"
    of 146:
      "Weapon Specialization (handaxe)"
    of 147:
      "Weapon Specialization (throwing axe)"
    of 148:
      "Weapon Specialization (battleaxe)"
    of 149:
      "Weapon Specialization (greataxe)"
    of 150:
      "Weapon Specialization (halberd)"
    of 151:
      "Weapon Specialization (light hammer)"
    of 152:
      "Weapon Specialization (light flail)"
    of 153:
      "Weapon Specialization (warhammer)"
    of 154:
      "Weapon Specialization (heavy flail)"
    of 155:
      "Weapon Specialization (kama)"
    of 156:
      "Weapon Specialization (kukri)"
    of 158:
      "Weapon Specialization (shuriken)"
    of 159:
      "Weapon Specialization (scythe)"
    of 160:
      "Weapon Specialization (katana)"
    of 161:
      "Weapon Specialization (bastard sword)"
    of 163:
      "Weapon Specialization (dire mace)"
    of 164:
      "Weapon Specialization (double axe)"
    of 165:
      "Weapon Specialization (two-bladed sword)"
    of 166:
      "Spell Focus (Conjuration)"
    of 167:
      "Spell Focus (Divination)"
    of 168:
      "Spell Focus (Enchantment)"
    of 169:
      "Spell Focus (Evocation)"
    of 170:
      "Spell Focus (Illusion)"
    of 171:
      "Spell Focus (Necromancy)"
    of 172:
      "Spell Focus (Transmutation)"
    of 173:
      "Skill Focus (Concentration)"
    of 174:
      "Skill Focus (Disable Trap)"
    of 175:
      "Skill Focus (Discipline)"
    of 177:
      "Skill Focus (Heal)"
    of 178:
      "Skill Focus (Hide)"
    of 179:
      "Skill Focus (Listen)"
    of 180:
      "Skill Focus (Lore)"
    of 181:
      "Skill Focus (Move Silently)"
    of 182:
      "Skill Focus (Open Lock)"
    of 183:
      "Skill Focus (Parry)"
    of 184:
      "Skill Focus (Perform)"
    of 185:
      "Skill Focus (Persuade)"
    of 186:
      "Skill Focus (Pick Pocket)"
    of 187:
      "Skill Focus (Search)"
    of 188:
      "Skill Focus (Set Trap)"
    of 189:
      "Skill Focus (Spellcraft)"
    of 190:
      "Skill Focus (Spot)"
    of 192:
      "Skill Focus (Taunt)"
    of 193:
      "Skill Focus (Use Magic Device)"
    of 194:
      "Barbarian Fast Movement"
    of 195:
      "Uncanny Dodge I"
    of 196:
      "Damage Reduction 1"
    of 197:
      "Bardic Knowledge"
    of 198:
      "Nature Sense"
    of 199:
      "Animal Companion"
    of 200:
      "Woodland Stride"
    of 201:
      "Trackless Step"
    of 202:
      "Resist Nature's Lure"
    of 203:
      "Venom Immunity"
    of 204:
      "Flurry of Blows"
    of 206:
      "Evasion"
    of 207:
      "Monk Speed"
    of 208:
      "Still Mind"
    of 209:
      "Purity of Body"
    of 211:
      "Wholeness of Body"
    of 212:
      "Improved Evasion"
    of 213:
      "Ki Strike +1"
    of 214:
      "Diamond Body"
    of 215:
      "Diamond Soul"
    of 216:
      "Perfect Self"
    of 217:
      "Divine Grace"
    of 219:
      "Divine Health"
    of 221:
      "Sneak Attack (+1d6)"
    of 222:
      "Crippling Strike"
    of 223:
      "Defensive Roll"
    of 224:
      "Opportunist"
    of 225:
      "Skill Mastery"
    of 226:
      "Monster Uncanny Reflex"
    of 227:
      "Stonecunning"
    of 228:
      "Darkvision"
    of 229:
      "Hardiness vs. Poisons"
    of 230:
      "Hardiness vs. Spells"
    of 231:
      "Battle Training vs. Orcs"
    of 232:
      "Battle Training vs. Goblins"
    of 233:
      "Battle Training vs. Giants"
    of 234:
      "Skill Affinity (Lore)"
    of 235:
      "Immunity To Sleep"
    of 236:
      "Hardiness vs. Enchantments"
    of 237:
      "Skill Affinity (Listen)"
    of 238:
      "Skill Affinity (Search)"
    of 239:
      "Skill Affinity (Spot)"
    of 240:
      "Keen Sense"
    of 241:
      "Hardiness vs. Illusions"
    of 242:
      "Battle Training vs. Reptilians"
    of 243:
      "Skill Affinity (Concentration)"
    of 244:
      "Partial Skill Affinity (Listen)"
    of 245:
      "Partial Skill Affinity (Search)"
    of 246:
      "Partial Skill Affinity (Spot)"
    of 247:
      "Skill Affinity (Move Silently)"
    of 248:
      "Lucky"
    of 249:
      "Fearless"
    of 250:
      "Good Aim"
    of 251:
      "Uncanny Dodge II"
    of 252:
      "Uncanny Dodge III"
    of 253:
      "Uncanny Dodge IV"
    of 254:
      "Uncanny Dodge V"
    of 255:
      "Uncanny Dodge VI+"
    of 256:
      "Weapon Proficiency (Elf)"
    of 257:
      "Bard Song"
    of 258:
      "Quick To Master"
    of 259:
      "Slippery Mind"
    of 260:
      "Monk AC Bonus"
    of 261:
      "Favored Enemy: Dwarves"
    of 262:
      "Favored Enemy: Elves"
    of 263:
      "Favored Enemy: Gnomes"
    of 264:
      "Favored Enemy: Halflings"
    of 265:
      "Favored Enemy: Half-Elves"
    of 266:
      "Favored Enemy: Half-Orcs"
    of 267:
      "Favored Enemy: Humans"
    of 268:
      "Favored Enemy: Aberrations"
    of 269:
      "Favored Enemy: Animals"
    of 270:
      "Favored Enemy: Beasts"
    of 271:
      "Favored Enemy: Constructs"
    of 272:
      "Favored Enemy: Dragons"
    of 273:
      "Favored Enemy: Goblinoids"
    of 274:
      "Favored Enemy: Monstrous Humanoids"
    of 275:
      "Favored Enemy: Orcs"
    of 276:
      "Favored Enemy: Reptilian Humanoids"
    of 277:
      "Favored Enemy: Elementals"
    of 278:
      "Favored Enemy: Fey"
    of 279:
      "Favored Enemy: Giants"
    of 280:
      "Favored Enemy: Magical Beasts"
    of 281:
      "Favored Enemy: Outsiders"
    of 284:
      "Favored Enemy: Shapechangers"
    of 285:
      "Favored Enemy: Undead"
    of 286:
      "Favored Enemy: Vermin"
    of 289:
      "Weapon Proficiency (creature)"
    of 290:
      "Weapon Specialization (creature)"
    of 291:
      "Weapon Focus (creature)"
    of 292:
      "Improved Critical (creature)"
    of 293:
      "Barbarian Rage (1x per day)"
    of 294:
      "Turn Undead"
    of 296:
      "Quivering Palm"
    of 297:
      "Empty Body"
    of 299:
      "Lay on Hands"
    of 300:
      "Aura of Courage"
    of 301:
      "Smite Evil"
    of 302:
      "Remove Disease"
    of 303:
      "Summon Familiar"
    of 304:
      "Elemental Shape"
    of 305:
      "Wild Shape"
    of 306:
      "War Domain Powers"
    of 307:
      "Strength Domain Powers"
    of 308:
      "Protection Domain Powers"
    of 310:
      "Death Domain Powers"
    of 311:
      "Air Domain Powers"
    of 312:
      "Animal Domain Powers"
    of 313:
      "Destruction Domain Powers"
    of 314:
      "Earth Domain Powers"
    of 315:
      "Evil Domain Powers"
    of 316:
      "Fire Domain Powers"
    of 317:
      "Good Domain Powers"
    of 318:
      "Healing Domain Powers"
    of 319:
      "Knowledge Domain Powers"
    of 320:
      "Magic Domain Powers"
    of 321:
      "Plant Domain Powers"
    of 322:
      "Sun Domain Powers"
    of 323:
      "Travel Domain Powers"
    of 324:
      "Trickery Domain Powers"
    of 325:
      "Water Domain Powers"
    of 326:
      "Barbarian Rage (2x per day)"
    of 327:
      "Barbarian Rage (3x per day)"
    of 328:
      "Barbarian Rage (4x per day)"
    of 329:
      "Greater Rage (4x per day)"
    of 330:
      "Greater Rage (5x per day)"
    of 331:
      "Greater Rage"
    of 332:
      "Damage Reduction 2"
    of 333:
      "Damage Reduction 3"
    of 334:
      "Damage Reduction 4"
    of 335:
      "Wild Shape (2x day)"
    of 336:
      "Wild Shape (3x day)"
    of 337:
      "Wild Shape (4x day)"
    of 338:
      "Wild Shape (5x day)"
    of 339:
      "Wild Shape"
    of 340:
      "Elemental Shape (2x day)"
    of 341:
      "Elemental Shape (3x day)"
    of 342:
      "Improved Elemental Shape"
    of 343:
      "Ki Strike +2"
    of 344:
      "Ki Strike +3"
    of 345:
      "Sneak Attack (+2d6)"
    of 346:
      "Sneak Attack (+3d6)"
    of 347:
      "Sneak Attack (+4d6)"
    of 348:
      "Sneak Attack (+5d6)"
    of 349:
      "Sneak Attack (+6d6)"
    of 350:
      "Sneak Attack (+7d6)"
    of 351:
      "Sneak Attack (+8d6)"
    of 352:
      "Sneak Attack (+9d6)"
    of 353:
      "Sneak Attack (+10d6)"
    of 354:
      "Low-light Vision"
    of 355:
      "Bard Song"
    of 356:
      "Bard Song"
    of 357:
      "Bard Song"
    of 358:
      "Bard Song"
    of 359:
      "Bard Song"
    of 360:
      "Bard Song"
    of 361:
      "Bard Song"
    of 362:
      "Bard Song"
    of 363:
      "Bard Song"
    of 364:
      "Bard Song"
    of 365:
      "Bard Song"
    of 366:
      "Bard Song"
    of 367:
      "Bard Song"
    of 368:
      "Bard Song"
    of 369:
      "Bard Song"
    of 370:
      "Bard Song"
    of 371:
      "Bard Song"
    of 372:
      "Bard Song"
    of 373:
      "Bard Song"
    of 374:
      "Dual-Wield"
    of 375:
      "Small Stature"
    of 377:
      "Improved Initiative"
    of 378:
      "Artist"
    of 379:
      "Blooded"
    of 380:
      "Bullheaded"
    of 381:
      "Courteous Magocracy"
    of 382:
      "Luck of Heroes"
    of 383:
      "Resist Poison"
    of 384:
      "Silver Palm"
    of 386:
      "Snake Blood"
    of 387:
      "Stealthy"
    of 388:
      "Strong Soul"
    of 389:
      "Expertise"
    of 390:
      "Improved Expertise"
    of 391:
      "Great Cleave"
    of 392:
      "Spring Attack"
    of 393:
      "Greater Spell Focus (Abjuration)"
    of 394:
      "Greater Spell Focus (Conjuration)"
    of 395:
      "Greater Spell Focus (Divination)"
    of 396:
      "Greater Spell Focus (Enchantment)"
    of 397:
      "Greater Spell Focus (Evocation)"
    of 398:
      "Greater Spell Focus (Illusion)"
    of 399:
      "Greater Spell Focus (Necromancy)"
    of 400:
      "Greater Spell Focus (Transmutation)"
    of 401:
      "Greater Spell Penetration"
    of 402:
      "Thug"
    of 404:
      "Skill Focus (Appraise)"
    of 406:
      "Skill Focus (Tumble)"
    of 407:
      "Skill Focus (Craft Trap)"
    of 408:
      "Blind-Fight"
    of 409:
      "Circle Kick"
    of 410:
      "Extra Stunning Attacks"
    of 411:
      "Rapid Reload"
    of 412:
      "Zen Archery"
    of 413:
      "Divine Might"
    of 414:
      "Divine Shield"
    of 415:
      "Arcane Defense (Abjuration)"
    of 416:
      "Arcane Defense (Conjuration)"
    of 417:
      "Arcane Defense (Divination)"
    of 418:
      "Arcane Defense (Enchantment)"
    of 419:
      "Arcane Defense (Evocation)"
    of 420:
      "Arcane Defense (Illusion)"
    of 421:
      "Arcane Defense (Necromancy)"
    of 422:
      "Arcane Defense (Transmutation)"
    of 423:
      "Extra Music"
    of 424:
      "Lingering Song"
    of 425:
      "Dirty Fighting"
    of 426:
      "Resist Disease"
    of 427:
      "Resist Cold Energy"
    of 428:
      "Resist Acid Energy"
    of 429:
      "Resist Fire Energy"
    of 430:
      "Resist Electrical Energy"
    of 431:
      "Resist Sonic Energy"
    of 433:
      "Hide in Plain Sight"
    of 434:
      "Shadow Daze"
    of 435:
      "Summon Shadow"
    of 436:
      "Shadow Evade"
    of 437:
      "Deneir's Eye"
    of 438:
      "Tymora's Smile"
    of 439:
      "Lliira's Heart"
    of 440:
      "Craft Harper Item"
    of 441:
      "Sleep"
    of 442:
      "Cat's Grace"
    of 443:
      "Eagle's Splendor"
    of 444:
      "Invisibility"
    of 445:
      "Enchant Arrow I"
    of 446:
      "Enchant Arrow II"
    of 447:
      "Enchant Arrow III"
    of 448:
      "Enchant Arrow IV"
    of 449:
      "Enchant Arrow V"
    of 450:
      "Imbue Arrow"
    of 451:
      "Seeker Arrow I"
    of 452:
      "Seeker Arrow II"
    of 453:
      "Hail of Arrows"
    of 454:
      "Arrow of Death"
    of 455:
      "Death Attack (+1d6)"
    of 456:
      "Death Attack (+2d6)"
    of 457:
      "Death Attack (+3d6)"
    of 458:
      "Death Attack (+4d6)"
    of 459:
      "Death Attack (+5d6)"
    of 460:
      "Sneak Attack, Blackguard (+1d6)"
    of 461:
      "Sneak Attack, Blackguard (+2d6)"
    of 462:
      "Sneak Attack, Blackguard (+3d6)"
    of 463:
      "Poison Save I"
    of 464:
      "Poison Save II"
    of 465:
      "Poison Save III"
    of 466:
      "Poison Save IV"
    of 467:
      "Poison Save V"
    of 468:
      "Ghostly Visage"
    of 469:
      "Darkness"
    of 470:
      "Invisibility"
    of 471:
      "Improved Invisibility"
    of 472:
      "Smite Good"
    of 473:
      "Dark Blessing"
    of 474:
      "Create Undead"
    of 475:
      "Summon Fiend"
    of 476:
      "Inflict Serious Wounds"
    of 477:
      "Inflict Critical Wounds"
    of 478:
      "Bull's Strength"
    of 479:
      "Contagion"
    of 488:
      "Blindsight, 60 foot radius"
    of 490:
      "Armor Skin"
    of 491:
      "Blinding Speed"
    of 492:
      "Epic Damage Reduction I"
    of 493:
      "Epic Damage Reduction II"
    of 494:
      "Epic Damage Reduction III"
    of 495:
      "Devastating Critical (club)"
    of 496:
      "Devastating Critical (dagger)"
    of 497:
      "Devastating Critical (dart)"
    of 498:
      "Devastating Critical (heavy crossbow)"
    of 499:
      "Devastating Critical (light crossbow)"
    of 500:
      "Devastating Critical (mace)"
    of 501:
      "Devastating Critical (morningstar)"
    of 502:
      "Devastating Critical (quarterstaff)"
    of 503:
      "Devastating Critical (spear)"
    of 504:
      "Devastating Critical (sickle)"
    of 505:
      "Devastating Critical (sling)"
    of 506:
      "Devastating Critical (unarmed strike)"
    of 507:
      "Devastating Critical (longbow)"
    of 508:
      "Devastating Critical (shortbow)"
    of 509:
      "Devastating Critical (shortsword)"
    of 510:
      "Devastating Critical (rapier)"
    of 511:
      "Devastating Critical (scimitar)"
    of 512:
      "Devastating Critical (longsword)"
    of 513:
      "Devastating Critical (greatsword)"
    of 514:
      "Devastating Critical (handaxe)"
    of 515:
      "Devastating Critical (throwing axe)"
    of 516:
      "Devastating Critical (battleaxe)"
    of 517:
      "Devastating Critical (greataxe)"
    of 518:
      "Devastating Critical (halberd)"
    of 519:
      "Devastating Critical (light hammer)"
    of 520:
      "Devastating Critical (light flail)"
    of 521:
      "Devastating Critical (warhammer)"
    of 522:
      "Devastating Critical (heavy flail)"
    of 523:
      "Devastating Critical (kama)"
    of 524:
      "Devastating Critical (kukri)"
    of 525:
      "Devastating Critical (shuriken)"
    of 526:
      "Devastating Critical (scythe)"
    of 527:
      "Devastating Critical (katana)"
    of 528:
      "Devastating Critical (bastard sword)"
    of 529:
      "Devastating Critical (dire mace)"
    of 530:
      "Devastating Critical (double axe)"
    of 531:
      "Devastating Critical (two-bladed sword)"
    of 532:
      "Devastating Critical (creature)"
    of 533:
      "Energy Resistance, Cold I"
    of 534:
      "Energy Resistance, Cold II"
    of 535:
      "Energy Resistance, Cold III"
    of 536:
      "Energy Resistance, Cold IV"
    of 537:
      "Energy Resistance, Cold V"
    of 538:
      "Energy Resistance, Cold VI"
    of 539:
      "Energy Resistance, Cold VII"
    of 540:
      "Energy Resistance, Cold VIII"
    of 541:
      "Energy Resistance, Cold IX"
    of 542:
      "Energy Resistance, Cold X"
    of 543:
      "Energy Resistance, Acid I"
    of 544:
      "Energy Resistance, Acid II"
    of 545:
      "Energy Resistance, Acid III"
    of 546:
      "Energy Resistance, Acid IV"
    of 547:
      "Energy Resistance, Acid V"
    of 548:
      "Energy Resistance, Acid VI"
    of 549:
      "Energy Resistance, Acid VII"
    of 550:
      "Energy Resistance, Acid VIII"
    of 551:
      "Energy Resistance, Acid IX"
    of 552:
      "Energy Resistance, Acid X"
    of 553:
      "Energy Resistance, Fire I"
    of 554:
      "Energy Resistance, Fire II"
    of 555:
      "Energy Resistance, Fire III"
    of 556:
      "Energy Resistance, Fire IV"
    of 557:
      "Energy Resistance, Fire V"
    of 558:
      "Energy Resistance, Fire VI"
    of 559:
      "Energy Resistance, Fire VII"
    of 560:
      "Energy Resistance, Fire VIII"
    of 561:
      "Energy Resistance, Fire IX"
    of 562:
      "Energy Resistance, Fire X"
    of 563:
      "Energy Resistance, Electrical I"
    of 564:
      "Energy Resistance, Electrical II"
    of 565:
      "Energy Resistance, Electrical III"
    of 566:
      "Energy Resistance, Electrical IV"
    of 567:
      "Energy Resistance, Electrical V"
    of 568:
      "Energy Resistance, Electrical VI"
    of 569:
      "Energy Resistance, Electrical VII"
    of 570:
      "Energy Resistance, Electrical VIII"
    of 571:
      "Energy Resistance, Electrical IX"
    of 572:
      "Energy Resistance, Electrical X"
    of 573:
      "Energy Resistance, Sonic I"
    of 574:
      "Energy Resistance, Sonic II"
    of 575:
      "Energy Resistance, Sonic III"
    of 576:
      "Energy Resistance, Sonic IV"
    of 577:
      "Energy Resistance, Sonic V"
    of 578:
      "Energy Resistance, Sonic VI"
    of 579:
      "Energy Resistance, Sonic VII"
    of 580:
      "Energy Resistance, Sonic VIII"
    of 581:
      "Energy Resistance, Sonic IX"
    of 582:
      "Energy Resistance, Sonic X"
    of 583:
      "Epic Fortitude"
    of 584:
      "Epic Prowess"
    of 585:
      "Epic Reflexes"
    of 586:
      "Epic Reputation"
    of 587:
      "Epic Skill Focus (Animal Empathy)"
    of 588:
      "Epic Skill Focus (Appraise)"
    of 589:
      "Epic Skill Focus (Concentration)"
    of 590:
      "Epic Skill Focus (Craft Trap)"
    of 591:
      "Epic Skill Focus (Disable Trap)"
    of 592:
      "Epic Skill Focus (Discipline)"
    of 593:
      "Epic Skill Focus (Heal)"
    of 594:
      "Epic Skill Focus (Hide)"
    of 595:
      "Epic Skill Focus (Listen)"
    of 596:
      "Epic Skill Focus (Lore)"
    of 597:
      "Epic Skill Focus (Move Silently)"
    of 598:
      "Epic Skill Focus (Open Lock)"
    of 599:
      "Epic Skill Focus (Parry)"
    of 600:
      "Epic Skill Focus (Perform)"
    of 601:
      "Epic Skill Focus (Persuade)"
    of 602:
      "Epic Skill Focus (Pick Pocket)"
    of 603:
      "Epic Skill Focus (Search)"
    of 604:
      "Epic Skill Focus (Set Trap)"
    of 605:
      "Epic Skill Focus (Spellcraft)"
    of 606:
      "Epic Skill Focus (Spot)"
    of 607:
      "Epic Skill Focus (Taunt)"
    of 608:
      "Epic Skill Focus (Tumble)"
    of 609:
      "Epic Skill Focus (Use Magic Device)"
    of 610:
      "Epic Spell Focus (Abjuration)"
    of 611:
      "Epic Spell Focus (Conjuration)"
    of 612:
      "Epic Spell Focus (Divination)"
    of 613:
      "Epic Spell Focus (Enchantment)"
    of 614:
      "Epic Spell Focus (Evocation)"
    of 615:
      "Epic Spell Focus (Illusion)"
    of 616:
      "Epic Spell Focus (Necromancy)"
    of 617:
      "Epic Spell Focus (Transmutation)"
    of 618:
      "Epic Spell Penetration"
    of 619:
      "Epic Weapon Focus (club)"
    of 620:
      "Epic Weapon Focus (dagger)"
    of 621:
      "Epic Weapon Focus (dart)"
    of 622:
      "Epic Weapon Focus (heavy crossbow)"
    of 623:
      "Epic Weapon Focus (light crossbow)"
    of 624:
      "Epic Weapon Focus (mace)"
    of 625:
      "Epic Weapon Focus (morningstar)"
    of 626:
      "Epic Weapon Focus (quarterstaff)"
    of 627:
      "Epic Weapon Focus (spear)"
    of 628:
      "Epic Weapon Focus (sickle)"
    of 629:
      "Epic Weapon Focus (sling)"
    of 630:
      "Epic Weapon Focus (unarmed strike)"
    of 631:
      "Epic Weapon Focus (longbow)"
    of 632:
      "Epic Weapon Focus (shortbow)"
    of 633:
      "Epic Weapon Focus (shortsword)"
    of 634:
      "Epic Weapon Focus (rapier)"
    of 635:
      "Epic Weapon Focus (scimitar)"
    of 636:
      "Epic Weapon Focus (longsword)"
    of 637:
      "Epic Weapon Focus (greatsword)"
    of 638:
      "Epic Weapon Focus (handaxe)"
    of 639:
      "Epic Weapon Focus (throwing axe)"
    of 640:
      "Epic Weapon Focus (battleaxe)"
    of 641:
      "Epic Weapon Focus (greataxe)"
    of 642:
      "Epic Weapon Focus (halberd)"
    of 643:
      "Epic Weapon Focus (light hammer)"
    of 644:
      "Epic Weapon Focus (light flail)"
    of 645:
      "Epic Weapon Focus (warhammer)"
    of 646:
      "Epic Weapon Focus (heavy flail)"
    of 647:
      "Epic Weapon Focus (kama)"
    of 648:
      "Epic Weapon Focus (kukri)"
    of 649:
      "Epic Weapon Focus (shuriken)"
    of 650:
      "Epic Weapon Focus (scythe)"
    of 651:
      "Epic Weapon Focus (katana)"
    of 652:
      "Epic Weapon Focus (bastard sword)"
    of 653:
      "Epic Weapon Focus (dire mace)"
    of 654:
      "Epic Weapon Focus (double axe)"
    of 655:
      "Epic Weapon Focus (two-bladed sword)"
    of 656:
      "Epic Weapon Focus (creature weapon)"
    of 657:
      "Epic Weapon Specialization (club)"
    of 658:
      "Epic Weapon Specialization (dagger)"
    of 659:
      "Epic Weapon Specialization (dart)"
    of 660:
      "Epic Weapon Specialization (heavy crossbow)"
    of 661:
      "Epic Weapon Specialization (light crossbow)"
    of 662:
      "Epic Weapon Specialization (mace)"
    of 663:
      "Epic Weapon Specialization (morningstar)"
    of 664:
      "Epic Weapon Specialization (quarterstaff)"
    of 665:
      "Epic Weapon Specialization (spear)"
    of 666:
      "Epic Weapon Specialization (sickle)"
    of 667:
      "Epic Weapon Specialization (sling)"
    of 668:
      "Epic Weapon Specialization (unarmed strike)"
    of 669:
      "Epic Weapon Specialization (longbow)"
    of 670:
      "Epic Weapon Specialization (shortbow)"
    of 671:
      "Epic Weapon Specialization (shortsword)"
    of 672:
      "Epic Weapon Specialization (rapier)"
    of 673:
      "Epic Weapon Specialization (scimitar)"
    of 674:
      "Epic Weapon Specialization (longsword)"
    of 675:
      "Epic Weapon Specialization (greatsword)"
    of 676:
      "Epic Weapon Specialization (handaxe)"
    of 677:
      "Epic Weapon Specialization (throwing axe)"
    of 678:
      "Epic Weapon Specialization (battleaxe)"
    of 679:
      "Epic Weapon Specialization (greataxe)"
    of 680:
      "Epic Weapon Specialization (halberd)"
    of 681:
      "Epic Weapon Specialization (light hammer)"
    of 682:
      "Epic Weapon Specialization (light flail)"
    of 683:
      "Epic Weapon Specialization (warhammer)"
    of 684:
      "Epic Weapon Specialization (heavy flail)"
    of 685:
      "Epic Weapon Specialization (kama)"
    of 686:
      "Epic Weapon Specialization (kukri)"
    of 687:
      "Epic Weapon Specialization (shuriken)"
    of 688:
      "Epic Weapon Specialization (scythe)"
    of 689:
      "Epic Weapon Specialization (katana)"
    of 690:
      "Epic Weapon Specialization (bastard sword)"
    of 691:
      "Epic Weapon Specialization (dire mace)"
    of 692:
      "Epic Weapon Specialization (double axe)"
    of 693:
      "Epic Weapon Specialization (two-bladed sword)"
    of 694:
      "Epic Weapon Specialization (creature weapon)"
    of 695:
      "Epic Will"
    of 696:
      "Improved Combat Casting"
    of 697:
      "Improved Ki Strike +4"
    of 698:
      "Improved Ki Strike +5"
    of 699:
      "Improved Spell Resistance I"
    of 700:
      "Improved Spell Resistance II"
    of 701:
      "Improved Spell Resistance III"
    of 702:
      "Improved Spell Resistance IV"
    of 703:
      "Improved Spell Resistance V"
    of 704:
      "Improved Spell Resistance VI"
    of 705:
      "Improved Spell Resistance VII"
    of 706:
      "Improved Spell Resistance VIII"
    of 707:
      "Improved Spell Resistance IX"
    of 708:
      "Improved Spell Resistance X"
    of 709:
      "Overwhelming Critical (club)"
    of 710:
      "Overwhelming Critical (dagger)"
    of 711:
      "Overwhelming Critical (dart)"
    of 712:
      "Overwhelming Critical (heavy crossbow)"
    of 713:
      "Overwhelming Critical (light crossbow)"
    of 714:
      "Overwhelming Critical (mace)"
    of 715:
      "Overwhelming Critical (morningstar)"
    of 716:
      "Overwhelming Critical (quarterstaff)"
    of 717:
      "Overwhelming Critical (spear)"
    of 718:
      "Overwhelming Critical (sickle)"
    of 719:
      "Overwhelming Critical (sling)"
    of 720:
      "Overwhelming Critical (unarmed strike)"
    of 721:
      "Overwhelming Critical (longbow)"
    of 722:
      "Overwhelming Critical (shortbow)"
    of 723:
      "Overwhelming Critical (shortsword)"
    of 724:
      "Overwhelming Critical (rapier)"
    of 725:
      "Overwhelming Critical (scimitar)"
    of 726:
      "Overwhelming Critical (longsword)"
    of 727:
      "Overwhelming Critical (greatsword)"
    of 728:
      "Overwhelming Critical (handaxe)"
    of 729:
      "Overwhelming Critical (throwing axe)"
    of 730:
      "Overwhelming Critical (battleaxe)"
    of 731:
      "Overwhelming Critical (greataxe)"
    of 732:
      "Overwhelming Critical (halberd)"
    of 733:
      "Overwhelming Critical (light hammer)"
    of 734:
      "Overwhelming Critical (light flail)"
    of 735:
      "Overwhelming Critical (warhammer)"
    of 736:
      "Overwhelming Critical (heavy flail)"
    of 737:
      "Overwhelming Critical (kama)"
    of 738:
      "Overwhelming Critical (kukri)"
    of 739:
      "Overwhelming Critical (shuriken)"
    of 740:
      "Overwhelming Critical (scythe)"
    of 741:
      "Overwhelming Critical (katana)"
    of 742:
      "Overwhelming Critical (bastard sword)"
    of 743:
      "Overwhelming Critical (dire mace)"
    of 744:
      "Overwhelming Critical (double axe)"
    of 745:
      "Overwhelming Critical (two-bladed sword)"
    of 746:
      "Overwhelming Critical (creature weapon)"
    of 747:
      "Perfect Health"
    of 748:
      "Self-Concealment I"
    of 749:
      "Self-Concealment II"
    of 750:
      "Self-Concealment III"
    of 751:
      "Self-Concealment IV"
    of 752:
      "Self-Concealment V"
    of 753:
      "Superior Initiative"
    of 754:
      "Epic Toughness I"
    of 755:
      "Epic Toughness II"
    of 756:
      "Epic Toughness III"
    of 757:
      "Epic Toughness IV"
    of 758:
      "Epic Toughness V"
    of 759:
      "Epic Toughness VI"
    of 760:
      "Epic Toughness VII"
    of 761:
      "Epic Toughness VIII"
    of 762:
      "Epic Toughness IX"
    of 763:
      "Epic Toughness X"
    of 764:
      "Great Charisma I"
    of 765:
      "Great Charisma II"
    of 766:
      "Great Charisma III"
    of 767:
      "Great Charisma IV"
    of 768:
      "Great Charisma V"
    of 769:
      "Great Charisma VI"
    of 770:
      "Great Charisma VII"
    of 771:
      "Great Charisma VIII"
    of 772:
      "Great Charisma IX"
    of 773:
      "Great Charisma X"
    of 774:
      "Great Constitution I"
    of 775:
      "Great Constitution II"
    of 776:
      "Great Constitution III"
    of 777:
      "Great Constitution IV"
    of 778:
      "Great Constitution V"
    of 779:
      "Great Constitution VI"
    of 780:
      "Great Constitution VII"
    of 781:
      "Great Constitution VIII"
    of 782:
      "Great Constitution IX"
    of 783:
      "Great Constitution X"
    of 784:
      "Great Dexterity I"
    of 785:
      "Great Dexterity II"
    of 786:
      "Great Dexterity III"
    of 787:
      "Great Dexterity IV"
    of 788:
      "Great Dexterity V"
    of 789:
      "Great Dexterity VI"
    of 790:
      "Great Dexterity VII"
    of 791:
      "Great Dexterity VIII"
    of 792:
      "Great Dexterity IX"
    of 793:
      "Great Dexterity X"
    of 794:
      "Great Intelligence I"
    of 795:
      "Great Intelligence II"
    of 796:
      "Great Intelligence III"
    of 797:
      "Great Intelligence IV"
    of 798:
      "Great Intelligence V"
    of 799:
      "Great Intelligence VI"
    of 800:
      "Great Intelligence VII"
    of 801:
      "Great Intelligence VIII"
    of 802:
      "Great Intelligence IX"
    of 803:
      "Great Intelligence X"
    of 804:
      "Great Wisdom I"
    of 805:
      "Great Wisdom II"
    of 806:
      "Great Wisdom III"
    of 807:
      "Great Wisdom IV"
    of 808:
      "Great Wisdom V"
    of 809:
      "Great Wisdom VI"
    of 810:
      "Great Wisdom VII"
    of 811:
      "Great Wisdom VIII"
    of 812:
      "Great Wisdom IX"
    of 813:
      "Great Wisdom X"
    of 814:
      "Great Strength I"
    of 815:
      "Great Strength II"
    of 816:
      "Great Strength III"
    of 817:
      "Great Strength IV"
    of 818:
      "Great Strength V"
    of 819:
      "Great Strength VI"
    of 820:
      "Great Strength VII"
    of 821:
      "Great Strength VIII"
    of 822:
      "Great Strength IX"
    of 823:
      "Great Strength X"
    of 824:
      "Great Smiting I"
    of 825:
      "Great Smiting II"
    of 826:
      "Great Smiting III"
    of 827:
      "Great Smiting IV"
    of 828:
      "Great Smiting V"
    of 829:
      "Great Smiting VI"
    of 830:
      "Great Smiting VII"
    of 831:
      "Great Smiting VIII"
    of 832:
      "Great Smiting IX"
    of 833:
      "Great Smiting X"
    of 834:
      "Improved Sneak Attack I"
    of 835:
      "Improved Sneak Attack II"
    of 836:
      "Improved Sneak Attack III"
    of 837:
      "Improved Sneak Attack IV"
    of 838:
      "Improved Sneak Attack V"
    of 839:
      "Improved Sneak Attack VI"
    of 840:
      "Improved Sneak Attack VII"
    of 841:
      "Improved Sneak Attack VIII"
    of 842:
      "Improved Sneak Attack IX"
    of 843:
      "Improved Sneak Attack X"
    of 844:
      "Improved Stunning Fist I"
    of 845:
      "Improved Stunning Fist II"
    of 846:
      "Improved Stunning Fist III"
    of 847:
      "Improved Stunning Fist IV"
    of 848:
      "Improved Stunning Fist V"
    of 849:
      "Improved Stunning Fist VI"
    of 850:
      "Improved Stunning Fist VII"
    of 851:
      "Improved Stunning Fist VIII"
    of 852:
      "Improved Stunning Fist IX"
    of 853:
      "Improved Stunning Fist X"
    of 854:
      "Planar Turning"
    of 855:
      "Bane of Enemies"
    of 856:
      "Epic Dodge"
    of 857:
      "Automatic Quicken Spell I"
    of 858:
      "Automatic Quicken Spell II"
    of 859:
      "Automatic Quicken Spell III"
    of 860:
      "Automatic Silent Spell I"
    of 861:
      "Automatic Silent Spell II"
    of 862:
      "Automatic Silent Spell III"
    of 863:
      "Automatic Still Spell I"
    of 864:
      "Automatic Still Spell II"
    of 865:
      "Automatic Still Spell III"
    of 867:
      "Whirlwind Attack"
    of 868:
      "Improved Whirlwind Attack"
    of 869:
      "Mighty Rage"
    of 870:
      "Lasting Inspiration"
    of 871:
      "Curse Song"
    of 872:
      "Undead Shape"
    of 873:
      "Dragon Shape"
    of 874:
      "Epic Spell: Mummy Dust"
    of 875:
      "Epic Spell: Dragon Knight"
    of 876:
      "Epic Spell: Hellball"
    of 877:
      "Epic Spell: Epic Mage Armor"
    of 878:
      "Epic Spell: Greater Ruin"
    of 879:
      "Weapon of Choice (sickle)"
    of 880:
      "Weapon of Choice (kama)"
    of 881:
      "Weapon of Choice (kukri)"
    of 882:
      "Ki Damage"
    of 883:
      "Increased Multiplier"
    of 884:
      "Superior Weapon Focus"
    of 885:
      "Ki Critical"
    of 886:
      "Bone Skin"
    of 889:
      "Animate Dead"
    of 890:
      "Summon Undead"
    of 891:
      "Deathless Vigor"
    of 892:
      "Undead Graft I"
    of 893:
      "Undead Graft II"
    of 894:
      "Tough as Bone"
    of 895:
      "Summon Greater Undead"
    of 896:
      "Deathless Mastery"
    of 897:
      "Deathless Master Touch"
    of 898:
      "Greater Wildshape I (wyrmling shape)"
    of 900:
      "Greater Wildshape II"
    of 901:
      "Greater Wildshape III"
    of 902:
      "Humanoid Shape"
    of 903:
      "Greater Wildshape IV"
    of 904:
      "Sacred Defense"
    of 909:
      "Divine Wrath"
    of 910:
      "Extra Smiting"
    of 911:
      "Skill Focus (Craft Armor)"
    of 912:
      "Skill Focus (Craft Weapon)"
    of 913:
      "Epic Skill Focus (Craft Armor)"
    of 914:
      "Epic Skill Focus (Craft Weapon)"
    of 915:
      "Skill Focus (Bluff)"
    of 916:
      "Skill Focus (Intimidate)"
    of 917:
      "Epic Skill Focus (Bluff)"
    of 918:
      "Epic Skill Focus (Intimidate)"
    of 919:
      "Weapon of Choice (club)"
    of 920:
      "Weapon of Choice (dagger)"
    of 921:
      "Weapon of Choice (mace)"
    of 922:
      "Weapon of Choice (morningstar)"
    of 923:
      "Weapon of Choice (quarterstaff)"
    of 924:
      "Weapon of Choice (spear)"
    of 925:
      "Weapon of Choice (short sword)"
    of 926:
      "Weapon of Choice (rapier)"
    of 927:
      "Weapon of Choice (scimitar)"
    of 928:
      "Weapon of Choice (longsword)"
    of 929:
      "Weapon of Choice (greatsword)"
    of 930:
      "Weapon of Choice (handaxe)"
    of 931:
      "Weapon of Choice (battleaxe)"
    of 932:
      "Weapon of Choice (greataxe)"
    of 933:
      "Weapon of Choice (halberd)"
    of 934:
      "Weapon of Choice (light hammer)"
    of 935:
      "Weapon of Choice (light flail)"
    of 936:
      "Weapon of Choice (warhammer)"
    of 937:
      "Weapon of Choice (heavy flail)"
    of 938:
      "Weapon of Choice (scythe)"
    of 939:
      "Weapon of Choice (katana)"
    of 940:
      "Weapon of Choice (bastard sword)"
    of 941:
      "Weapon of Choice (dire mace)"
    of 942:
      "Weapon of Choice (double axe)"
    of 943:
      "Weapon of Choice (two-bladed sword)"
    of 944:
      "Brew Potion"
    of 945:
      "Scribe Scroll"
    of 946:
      "Craft Wand"
    of 947:
      "Defensive Stance"
    of 948:
      "Dwarven Defender Damage Reduction"
    of 949:
      "Defensive Awareness (1)"
    of 950:
      "Defensive Awareness (2)"
    of 951:
      "Defensive Awareness (3)"
    of 952:
      "Weapon Focus (dwarven waraxe)"
    of 953:
      "Weapon Specialization (dwarven waraxe)"
    of 954:
      "Improved Critical (dwarven waraxe)"
    of 955:
      "Devastating Critical (dwarven waraxe)"
    of 956:
      "Epic Weapon Focus (dwarven waraxe)"
    of 957:
      "Epic Weapon Specialization (dwarven waraxe)"
    of 958:
      "Overwhelming Critical (dwarven waraxe)"
    of 959:
      "Weapon of Choice (dwarven waraxe)"
    of 960:
      "Use Poison"
    of 961:
      "Draconic Armor"
    of 962:
      "Dragon Abilities"
    of 963:
      "Immunity to Paralysis"
    of 964:
      "Immunity to Fire"
    of 965:
      "Dragon Breath"
    of 966:
      "Epic Fighter"
    of 967:
      "Epic Barbarian"
    of 968:
      "Epic Bard"
    of 969:
      "Epic Cleric"
    of 970:
      "Epic Druid"
    of 971:
      "Epic Monk"
    of 972:
      "Epic Paladin"
    of 973:
      "Epic Ranger"
    of 974:
      "Epic Rogue"
    of 975:
      "Epic Sorcerer"
    of 976:
      "Epic Wizard"
    of 977:
      "Epic Arcane Archer"
    of 978:
      "Epic Assassin"
    of 979:
      "Epic Blackguard"
    of 980:
      "Epic Shadowdancer"
    of 982:
      "Epic Champion of Torm"
    of 983:
      "Epic Weapon Master"
    of 984:
      "Epic Palemaster"
    of 985:
      "Epic Dwarven Defender"
    of 986:
      "Epic Shifter"
    of 987:
      "Epic Red Dragon Disciple"
    of 988:
      "Thundering Rage"
    of 989:
      "Terrifying Rage"
    of 990:
      "Epic Spell: Epic Warding"
    of 993:
      "Weapon Focus (whip)"
    of 994:
      "Weapon Specialization (whip)"
    of 995:
      "Improved Critical (whip)"
    of 996:
      "Devastating Critical (whip)"
    of 997:
      "Epic Weapon Focus (whip)"
    of 998:
      "Epic Weapon Specialization (whip)"
    of 999:
      "Overwhelming Critical (whip)"
    of 1000:
      "Weapon of Choice (whip)"
    of 1001:
      "Epic Character"
    of 1002:
      "Epic Shadowlord"
    of 1003:
      "Epic Fiendish Servant"
    of 1004:
      "Death Attack (+6d6)"
    of 1005:
      "Death Attack (+7d6)"
    of 1006:
      "Death Attack (+8d6)"
    of 1007:
      "Sneak Attack, Blackguard (+4d6)"
    of 1008:
      "Sneak Attack, Blackguard (+5d6)"
    of 1009:
      "Sneak Attack, Blackguard (+6d6)"
    of 1010:
      "Sneak Attack, Blackguard (+7d6)"
    of 1011:
      "Sneak Attack, Blackguard (+8d6)"
    of 1012:
      "Sneak Attack, Blackguard (+9d6)"
    of 1013:
      "Sneak Attack, Blackguard (+10d6)"
    of 1014:
      "Sneak Attack, Blackguard (+11d6)"
    of 1015:
      "Sneak Attack, Blackguard (+12d6)"
    of 1016:
      "Sneak Attack, Blackguard (+13d6)"
    of 1017:
      "Sneak Attack, Blackguard (+14d6)"
    of 1018:
      "Sneak Attack, Blackguard (+15d6)"
    of 1019:
      "Death Attack (+9d6)"
    of 1020:
      "Death Attack (+10d6)"
    of 1021:
      "Death Attack (+11d6)"
    of 1022:
      "Death Attack (+12d6)"
    of 1023:
      "Death Attack (+13d6)"
    of 1024:
      "Death Attack (+14d6)"
    of 1025:
      "Death Attack (+15d6)"
    of 1026:
      "Death Attack (+16d6)"
    of 1027:
      "Death Attack (+17d6)"
    of 1028:
      "Death Attack (+18d6)"
    of 1029:
      "Death Attack (+19d6)"
    of 1030:
      "Death Attack (+20d6)"
    of 1032:
      "Sneak Attack (+11d6)"
    of 1033:
      "Sneak Attack (+12d6)"
    of 1034:
      "Sneak Attack (+13d6)"
    of 1035:
      "Sneak Attack (+14d6)"
    of 1036:
      "Sneak Attack (+15d6)"
    of 1037:
      "Sneak Attack (+16d6)"
    of 1038:
      "Sneak Attack (+17d6)"
    of 1039:
      "Sneak Attack (+18d6)"
    of 1040:
      "Sneak Attack (+19d6)"
    of 1041:
      "Sneak Attack (+20d6)"
    of 1042:
      "Hit Die Increase (d6)"
    of 1043:
      "Hit Die Increase (d8)"
    of 1044:
      "Hit Die Increase (d10)"
    of 1045:
      "Enchant Arrow VI"
    of 1046:
      "Enchant Arrow VII"
    of 1047:
      "Enchant Arrow VIII"
    of 1048:
      "Enchant Arrow IX"
    of 1049:
      "Enchant Arrow X"
    of 1050:
      "Enchant Arrow XI"
    of 1051:
      "Enchant Arrow XII"
    of 1052:
      "Enchant Arrow XIII"
    of 1053:
      "Enchant Arrow XIV"
    of 1054:
      "Enchant Arrow XV"
    of 1055:
      "Enchant Arrow XVI"
    of 1056:
      "Enchant Arrow XVII"
    of 1057:
      "Enchant Arrow XVIII"
    of 1058:
      "Enchant Arrow XIX"
    of 1059:
      "Enchant Arrow XX"
    of 1060:
      "Outsider Shape"
    of 1061:
      "Construct Shape"
    of 1062:
      "Infinite Greater Wildshape I"
    of 1063:
      "Infinite Greater Wildshape II"
    of 1064:
      "Infinite Greater Wildshape III"
    of 1065:
      "Infinite Greater Wildshape IV"
    of 1066:
      "Infinite Humanoid Shape"
    of 1067:
      "Epic Barbarian Damage Reduction"
    of 1068:
      "Infinite Wildshape"
    of 1069:
      "Infinite Elemental Shape"
    of 1070:
      "Poison Save VI+"
    of 1071:
      "Epic Superior Weapon Focus"
    else:
      "Unkown"

# get Spell
proc bicSpell*(num: word): string =
  result = case num:
    of 0:
      "Acid Fog"
    of 1:
      "Aid"
    of 2:
      "Animate Dead"
    of 3:
      "Barkskin"
    of 4:
      "Bestow Curse"
    of 5:
      "Blade Barrier"
    of 6:
      "Bless"
    of 8:
      "Blindness/Deafness"
    of 9:
      "Bull's Strength"
    of 10:
      "Burning Hands"
    of 11:
      "Call Lightning"
    of 13:
      "Cat's Grace"
    of 14:
      "Chain Lightning"
    of 15:
      "Charm Monster"
    of 16:
      "Charm Person"
    of 17:
      "Charm Person or Animal"
    of 18:
      "Circle of Death"
    of 19:
      "Circle of Doom"
    of 20:
      "Clairaudience/Clairvoyance"
    of 21:
      "Clarity"
    of 23:
      "Cloudkill"
    of 24:
      "Color Spray"
    of 25:
      "Cone of Cold"
    of 26:
      "Confusion"
    of 27:
      "Contagion"
    of 28:
      "Control Undead"
    of 29:
      "Create Greater Undead"
    of 30:
      "Create Undead"
    of 31:
      "Cure Critical Wounds"
    of 32:
      "Cure Light Wounds"
    of 33:
      "Cure Minor Wounds"
    of 34:
      "Cure Moderate Wounds"
    of 35:
      "Cure Serious Wounds"
    of 36:
      "Darkness"
    of 37:
      "Daze"
    of 38:
      "Death Ward"
    of 39:
      "Delayed Blast Fireball"
    of 40:
      "Dismissal"
    of 41:
      "Dispel Magic"
    of 42:
      "Divine Power"
    of 43:
      "Dominate Animal"
    of 44:
      "Dominate Monster"
    of 45:
      "Dominate Person"
    of 46:
      "Doom"
    of 47:
      "Elemental Shield"
    of 48:
      "Elemental Swarm"
    of 49:
      "Endurance"
    of 50:
      "Endure Elements"
    of 51:
      "Energy Drain"
    of 52:
      "Enervation"
    of 53:
      "Entangle"
    of 54:
      "Fear"
    of 55:
      "Feeblemind"
    of 56:
      "Finger of Death"
    of 57:
      "Fire Storm"
    of 58:
      "Fireball"
    of 59:
      "Flame Arrow"
    of 60:
      "Flame Lash"
    of 61:
      "Flame Strike"
    of 62:
      "Freedom of Movement"
    of 63:
      "Gate"
    of 64:
      "Ghoul Touch"
    of 65:
      "Globe of Invulnerability"
    of 66:
      "Grease"
    of 67:
      "Greater Dispelling"
    of 69:
      "Greater Planar Binding"
    of 70:
      "Greater Restoration"
    of 71:
      "Greater Shadow Conjuration"
    of 72:
      "Greater Spell Breach"
    of 73:
      "Greater Spell Mantle"
    of 74:
      "Greater Stoneskin"
    of 75:
      "Gust of Wind"
    of 76:
      "Hammer of the Gods"
    of 77:
      "Harm"
    of 78:
      "Haste"
    of 79:
      "Heal"
    of 80:
      "Healing Circle"
    of 81:
      "Hold Animal"
    of 82:
      "Hold Monster"
    of 83:
      "Hold Person"
    of 84:
      "Holy Aura"
    of 86:
      "Identify"
    of 87:
      "Implosion"
    of 88:
      "Improved Invisibility"
    of 89:
      "Incendiary Cloud"
    of 90:
      "Invisibility"
    of 91:
      "Invisibility Purge"
    of 92:
      "Invisibility Sphere"
    of 93:
      "Knock"
    of 94:
      "Lesser Dispel"
    of 95:
      "Lesser Mind Blank"
    of 96:
      "Lesser Planar Binding"
    of 97:
      "Lesser Restoration"
    of 98:
      "Lesser Spell Breach"
    of 99:
      "Lesser Spell Mantle"
    of 100:
      "Light"
    of 101:
      "Lightning Bolt"
    of 102:
      "Mage Armor"
    of 104:
      "Magic Circle against Evil"
    of 105:
      "Magic Circle against Good"
    of 107:
      "Magic Missile"
    of 110:
      "Mass Blindness/Deafness"
    of 111:
      "Mass Charm"
    of 113:
      "Mass Haste"
    of 114:
      "Mass Heal"
    of 115:
      "Melf's Acid Arrow"
    of 116:
      "Meteor Swarm"
    of 117:
      "Mind Blank"
    of 118:
      "Mind Fog"
    of 119:
      "Minor Globe of Invulnerability"
    of 120:
      "Ghostly Visage"
    of 121:
      "Ethereal Visage"
    of 122:
      "Mordenkainen's Disjunction"
    of 123:
      "Mordenkainen's Sword"
    of 124:
      "Nature's Balance"
    of 125:
      "Negative Energy Protection"
    of 126:
      "Neutralize Poison"
    of 127:
      "Phantasmal Killer"
    of 128:
      "Planar Binding"
    of 129:
      "Poison"
    of 130:
      "Polymorph Self"
    of 131:
      "Power Word, Kill"
    of 132:
      "Power Word, Stun"
    of 133:
      "Prayer"
    of 134:
      "Premonition"
    of 135:
      "Prismatic Spray"
    of 137:
      "Protection from Elements"
    of 138:
      "Protection from Evil"
    of 139:
      "Protection from Good"
    of 141:
      "Protection from Spells"
    of 142:
      "Raise Dead"
    of 143:
      "Ray of Enfeeblement"
    of 144:
      "Ray of Frost"
    of 145:
      "Remove Blindness/Deafness"
    of 146:
      "Remove Curse"
    of 147:
      "Remove Disease"
    of 148:
      "Remove Fear"
    of 149:
      "Remove Paralysis"
    of 150:
      "Resist Elements"
    of 151:
      "Resistance"
    of 152:
      "Restoration"
    of 153:
      "Resurrection"
    of 154:
      "Sanctuary"
    of 155:
      "Scare"
    of 156:
      "Searing Light"
    of 157:
      "See Invisibility"
    of 158:
      "Shades"
    of 159:
      "Shadow Conjuration"
    of 160:
      "Shadow Shield"
    of 161:
      "Shapechange"
    of 163:
      "Silence"
    of 164:
      "Slay Living"
    of 165:
      "Sleep"
    of 166:
      "Slow"
    of 167:
      "Sound Burst"
    of 168:
      "Spell Resistance"
    of 169:
      "Spell Mantle"
    of 171:
      "Stinking Cloud"
    of 172:
      "Stoneskin"
    of 173:
      "Storm of Vengeance"
    of 174:
      "Summon Creature I"
    of 175:
      "Summon Creature II"
    of 176:
      "Summon Creature III"
    of 177:
      "Summon Creature IV"
    of 178:
      "Summon Creature IX"
    of 179:
      "Summon Creature V"
    of 180:
      "Summon Creature VI"
    of 181:
      "Summon Creature VII"
    of 182:
      "Summon Creature VIII"
    of 183:
      "Sunbeam"
    of 184:
      "Tenser's Transformation"
    of 185:
      "Time Stop"
    of 186:
      "True Seeing"
    of 187:
      "Unholy Aura"
    of 188:
      "Vampiric Touch"
    of 189:
      "Virtue"
    of 190:
      "Wail of the Banshee"
    of 191:
      "Wall of Fire"
    of 192:
      "Web"
    of 193:
      "Weird"
    of 194:
      "Word of Faith"
    of 195:
      "Aura of Blinding"
    of 196:
      "Aura of Cold"
    of 197:
      "Aura of Electricity"
    of 198:
      "Aura of Fear"
    of 199:
      "Aura of Fire"
    of 200:
      "Aura of Menace"
    of 201:
      "Aura of Protection"
    of 202:
      "Aura of Stunning"
    of 203:
      "Aura of Unearthly Visage"
    of 204:
      "Aura of Unnatural"
    of 205:
      "Bolt, Ability Drain Charisma"
    of 206:
      "Bolt, Ability Drain Constitution"
    of 207:
      "Bolt, Ability Drain Dexterity"
    of 208:
      "Bolt, Ability Drain Intelligence"
    of 209:
      "Bolt, Ability Drain Strength"
    of 210:
      "Bolt, Ability Drain Wisdom"
    of 211:
      "Bolt, Acid"
    of 212:
      "Bolt, Charm"
    of 213:
      "Bolt, Cold"
    of 214:
      "Bolt, Confuse"
    of 215:
      "Bolt, Daze"
    of 216:
      "Bolt, Death"
    of 217:
      "Bolt, Disease"
    of 218:
      "Bolt, Dominate"
    of 219:
      "Bolt, Fire"
    of 220:
      "Bolt, Knockdown"
    of 221:
      "Bolt, Level Drain"
    of 222:
      "Bolt, Lightning"
    of 223:
      "Bolt, Paralyze"
    of 224:
      "Bolt, Poison"
    of 225:
      "Bolt, Shards"
    of 226:
      "Bolt, Slow"
    of 227:
      "Bolt, Stun"
    of 228:
      "Bolt, Web"
    of 229:
      "Cone of Acid"
    of 230:
      "Cone of Frost"
    of 231:
      "Cone of Disease"
    of 232:
      "Cone of Fire"
    of 233:
      "Cone of Lightning"
    of 234:
      "Cone of Poison"
    of 235:
      "Cone, Sonic"
    of 236:
      "Dragon Breath, Acid"
    of 237:
      "Dragon Breath, Cold"
    of 238:
      "Dragon Breath, Fear"
    of 239:
      "Dragon Breath, Fire"
    of 240:
      "Dragon Breath, Gas"
    of 241:
      "Dragon Breath, Lightning"
    of 242:
      "Dragon Breath, Paralysis"
    of 243:
      "Dragon Breath, Sleep"
    of 244:
      "Dragon Breath, Slow"
    of 245:
      "Dragon Breath, Weaken"
    of 247:
      "Ferocity"
    of 248:
      "Ferocity, Improved"
    of 249:
      "Ferocity, Greater"
    of 250:
      "Gaze, Charm"
    of 251:
      "Gaze, Confusion"
    of 252:
      "Gaze, Daze"
    of 253:
      "Gaze, Death"
    of 254:
      "Gaze, Destroy Chaos"
    of 255:
      "Gaze, Destroy Evil"
    of 256:
      "Gaze, Destroy Good"
    of 257:
      "Gaze, Destroy Law"
    of 258:
      "Gaze, Dominate"
    of 259:
      "Gaze, Doom"
    of 260:
      "Gaze, Fear"
    of 261:
      "Gaze, Paralysis"
    of 262:
      "Gaze, Stunned"
    of 263:
      "Iron Golem Poison Gas"
    of 264:
      "Hell Hound Fire Breath"
    of 265:
      "Howl, Confusion"
    of 266:
      "Howl, Daze"
    of 267:
      "Howl, Death"
    of 268:
      "Howl, Doom"
    of 269:
      "Howl, Fear"
    of 270:
      "Howl, Paralysis"
    of 271:
      "Howl, Sonic"
    of 272:
      "Howl, Stunning"
    of 273:
      "Intensity"
    of 274:
      "Intensity, Improved"
    of 275:
      "Intensity, Greater"
    of 276:
      "Krenshar, Fear Gaze"
    of 277:
      "Lesser Body Adjustment"
    of 278:
      "Mephit, Salt Breath"
    of 279:
      "Mephit, Steam Breath"
    of 280:
      "Mummy, Bolster Undead"
    of 281:
      "Pulse, Water Elemental Drown"
    of 282:
      "Pulse, Vrock Spores"
    of 283:
      "Pulse, Air Elemental Whirlwind"
    of 284:
      "Pulse, Fire"
    of 285:
      "Pulse, Lightning"
    of 286:
      "Pulse, Cold"
    of 287:
      "Pulse, Negative"
    of 288:
      "Pulse, Holy"
    of 289:
      "Pulse, Death"
    of 290:
      "Pulse, Level Drain"
    of 291:
      "Pulse, Ability Drain Intelligence"
    of 292:
      "Pulse, Ability Drain Charisma"
    of 293:
      "Pulse, Ability Drain Constitution"
    of 294:
      "Pulse, Ability Drain Dexterity"
    of 295:
      "Pulse, Ability Drain Strength"
    of 296:
      "Pulse, Ability Drain Wisdom"
    of 297:
      "Pulse, Poison"
    of 298:
      "Pulse, Disease"
    of 299:
      "Rage"
    of 300:
      "Rage, Improved"
    of 301:
      "Rage, Greater"
    of 303:
      "Summon Slaad"
    of 304:
      "Summon Tanarri"
    of 306:
      "Tyrant Fog Zombie Mist"
    of 307:
      "Barbarian Rage (1x per day)"
    of 308:
      "Turn Undead"
    of 309:
      "Trap Kit"
    of 310:
      "Quivering Palm"
    of 311:
      "Empty Body"
    of 312:
      "<DELETED>"
    of 313:
      "Lay on Hands"
    of 314:
      "Aura of Courage"
    of 315:
      "Smite Evil"
    of 316:
      "Remove Disease"
    of 317:
      "Summon Animal Companion"
    of 318:
      "Summon Familiar"
    of 319:
      "Elemental Shape"
    of 320:
      "Wild Shape"
    of 321:
      "Protection from Alignment"
    of 322:
      "Magic Circle against Alignment"
    of 323:
      "Aura versus Alignment"
    of 324:
      "Summon Shadow"
    of 325:
      "Protection from Cold"
    of 326:
      "Protection from Fire"
    of 327:
      "Protection from Acid"
    of 328:
      "Protection from Sonic"
    of 329:
      "Protection from Lightning"
    of 330:
      "Endure Cold"
    of 331:
      "Endure Fire"
    of 332:
      "Endure Acid"
    of 333:
      "Endure Sonic"
    of 334:
      "Endure Lightning"
    of 335:
      "Resist Cold"
    of 336:
      "Resist Fire"
    of 337:
      "Resist Acid"
    of 338:
      "Resist Sonic"
    of 339:
      "Resist Lightning"
    of 340:
      "Shades, Cone of Cold"
    of 341:
      "Shades, Fireball"
    of 342:
      "Shades, Stoneskin"
    of 343:
      "Shades, Wall of Fire"
    of 344:
      "Shadow Conjuration, Summon Shadow"
    of 345:
      "Shadow Conjuration, Darkness"
    of 346:
      "Shadow Conjuration, Invisibility"
    of 347:
      "Shadow Conjuration, Mage Armor"
    of 348:
      "Shadow Conjuration, Magic Missile"
    of 349:
      "Greater Shadow Conjuration, Summon Shadow"
    of 350:
      "Greater Shadow Conjuration, Acid Arrow"
    of 351:
      "Greater Shadow Conjuration, Ghostly Visage"
    of 352:
      "Greater Shadow Conjuration, Web"
    of 353:
      "Greater Shadow Conjuration, Minor Globe of Invulnerability"
    of 354:
      "Eagle's Splendor"
    of 355:
      "Owl's Wisdom"
    of 356:
      "Fox's Cunning"
    of 357:
      "Greater Eagle's Splendor"
    of 358:
      "Greater Owl's Wisdom"
    of 359:
      "Greater Fox's Cunning"
    of 360:
      "Greater Bull's Strength"
    of 361:
      "Greater Cat's Grace"
    of 362:
      "Greater Endurance"
    of 363:
      "Awaken"
    of 364:
      "Creeping Doom"
    of 365:
      "Ultravision"
    of 366:
      "Destruction"
    of 367:
      "Horrid Wilting"
    of 368:
      "Ice Storm"
    of 369:
      "Energy Buffer"
    of 370:
      "Negative Energy Burst"
    of 371:
      "Negative Energy Ray"
    of 372:
      "Aura of Vitality"
    of 373:
      "War Cry"
    of 374:
      "Regenerate"
    of 375:
      "Evard's Black Tentacles"
    of 376:
      "Legend Lore"
    of 377:
      "Find Traps"
    of 378:
      "Summon Mephit"
    of 379:
      "Summon Celestial"
    of 380:
      "War Domain, Battle Mastery"
    of 381:
      "Strength Domain, Divine Strength"
    of 382:
      "Protection Domain, Divine Protection"
    of 383:
      "Death Domain, Negative Plane Avatar"
    of 384:
      "Trickery Domain, Divine Trickery"
    of 385:
      "Rogue's Cunning"
    of 386:
      "Activate Item"
    of 387:
      "Polymorph, Giant Spider"
    of 388:
      "Polymorph, Troll"
    of 389:
      "Polymorph, Umber Hulk"
    of 390:
      "Polymorph, Fey"
    of 391:
      "Polymorph, Zombie"
    of 392:
      "Shapechange, Red Dragon"
    of 393:
      "Shapechange, Fire Giant"
    of 394:
      "Shapechange, Balor"
    of 395:
      "Shapechange, Death Slaad"
    of 396:
      "Shapechange, Iron Golem"
    of 397:
      "Elemental Shape, Fire"
    of 398:
      "Elemental Shape, Water"
    of 399:
      "Elemental Shape, Earth"
    of 400:
      "Elemental Shape, Air"
    of 401:
      "Wild Shape, Brown Bear"
    of 402:
      "Wild Shape, Panther"
    of 403:
      "Wild Shape, Wolf"
    of 404:
      "Wild Shape, Boar"
    of 405:
      "Wild Shape, Badger"
    of 406:
      "Alcohol, Beer"
    of 407:
      "Alcohol, Wine"
    of 408:
      "Alcohol, Spirits"
    of 409:
      "Herb, Belladonna"
    of 410:
      "Herb, Garlic"
    of 411:
      "Bard Song"
    of 412:
      "Aura, Dragon Fear"
    of 413:
      "Activate Item"
    of 414:
      "Divine Favor"
    of 415:
      "True Strike"
    of 416:
      "Flare"
    of 417:
      "Shield"
    of 418:
      "Entropic Shield"
    of 419:
      "Continual Flame"
    of 420:
      "One with the Land"
    of 421:
      "Camouflage"
    of 422:
      "Blood Frenzy"
    of 423:
      "Bombardment"
    of 424:
      "Acid Splash"
    of 425:
      "Quillfire"
    of 426:
      "Earthquake"
    of 427:
      "Sunburst"
    of 428:
      "Activate Item"
    of 429:
      "Aura of Glory"
    of 430:
      "Banishment"
    of 431:
      "Inflict Minor Wounds"
    of 432:
      "Inflict Light Wounds"
    of 433:
      "Inflict Moderate Wounds"
    of 434:
      "Inflict Serious Wounds"
    of 435:
      "Inflict Critical Wounds"
    of 436:
      "Balagarn's Iron Horn"
    of 437:
      "Drown"
    of 438:
      "Owl's Insight"
    of 439:
      "Electric Jolt"
    of 440:
      "Firebrand"
    of 441:
      "Wounding Whispers"
    of 442:
      "Amplify"
    of 443:
      "Greater Sanctuary"
    of 444:
      "Undeath's Eternal Foe"
    of 445:
      "Dirge"
    of 446:
      "Inferno"
    of 447:
      "Isaac's Lesser Missile Storm"
    of 448:
      "Isaac's Greater Missile Storm"
    of 449:
      "Bane"
    of 450:
      "Shield of Faith"
    of 451:
      "Planar Ally"
    of 452:
      "Magic Fang"
    of 453:
      "Greater Magic Fang"
    of 454:
      "Spike Growth"
    of 455:
      "Mass Camouflage"
    of 456:
      "Expeditious Retreat"
    of 457:
      "Tasha's Hideous Laughter"
    of 458:
      "Displacement"
    of 459:
      "Bigby's Interposing Hand"
    of 460:
      "Bigby's Forceful Hand"
    of 461:
      "Bigby's Grasping Hand"
    of 462:
      "Bigby's Clenched Fist"
    of 463:
      "Bigby's Crushing Hand"
    of 464:
      "Alchemist's Fire"
    of 465:
      "Tanglefoot Bag"
    of 466:
      "Holy Water"
    of 467:
      "Choking Powder"
    of 468:
      "Thunderstone"
    of 469:
      "Acid Flask"
    of 470:
      "Chickenegg"
    of 471:
      "Caltrops"
    of 472:
      "Manipulate Portal Stone"
    of 473:
      "Divine Might"
    of 474:
      "Divine Shield"
    of 475:
      "Shadow Daze"
    of 476:
      "Summon Shadow"
    of 477:
      "Shadow Evade"
    of 478:
      "Tymora's Smile"
    of 479:
      "Craft Harper Item"
    of 480:
      "Sleep"
    of 481:
      "Cat's Grace"
    of 482:
      "Eagle's Splendor"
    of 483:
      "Invisibility"
    of 485:
      "Flesh to Stone"
    of 486:
      "Stone to Flesh"
    of 487:
      "Arrow"
    of 488:
      "Bolt"
    of 493:
      "Dart"
    of 494:
      "Shuriken"
    of 495:
      "Breath, Petrification"
    of 496:
      "Touch, Petrification"
    of 497:
      "Gaze, Petrification"
    of 498:
      "Manticore Spikes"
    of 499:
      "Wondrous Gloves"
    of 500:
      "Primary Video Card"
    of 502:
      "Summoning Pool"
    of 503:
      "Negative Plane Avatar"
    of 504:
      "Color Spray"
    of 505:
      "Color Spray"
    of 507:
      "Power Stone"
    of 508:
      "Spellstaff"
    of 509:
      "Magical Electrifier - Charge"
    of 510:
      "Magical Electrifier - Destroy"
    of 511:
      "Kobold Jump"
    of 512:
      "Crumble"
    of 513:
      "Infestation of Maggots"
    of 514:
      "Healing Sting"
    of 515:
      "Great Thunderclap"
    of 516:
      "Ball Lightning"
    of 517:
      "Battletide"
    of 518:
      "Combust"
    of 519:
      "Death Armor"
    of 520:
      "Gedlee's Electric Loop"
    of 521:
      "Horizikaul's Boom"
    of 522:
      "Ironguts"
    of 523:
      "Mestil's Acid Breath"
    of 524:
      "Mestil's Acid Sheath"
    of 525:
      "Monstrous Regeneration"
    of 526:
      "Scintillating Sphere"
    of 527:
      "Stone Bones"
    of 528:
      "Undeath to Death"
    of 529:
      "Vine Mine"
    of 530:
      "Vine Mine, Entangle"
    of 531:
      "Vine Mine, Hamper Movement"
    of 532:
      "Vine Mine, Camouflage"
    of 533:
      "Black Blade of Disaster"
    of 534:
      "Shelgarn's Persistent Blade"
    of 535:
      "Blade Thirst"
    of 536:
      "Deafening Clang"
    of 537:
      "Bless Weapon"
    of 538:
      "Holy Sword"
    of 539:
      "Keen Edge"
    of 541:
      "Blackstaff"
    of 542:
      "Flame Weapon"
    of 543:
      "Ice Dagger"
    of 544:
      "Magic Weapon"
    of 545:
      "Greater Magic Weapon"
    of 546:
      "Magic Vestment"
    of 547:
      "Stonehold"
    of 548:
      "Darkfire"
    of 549:
      "Glyph of Warding"
    of 551:
      "Psionic Mind Blast"
    of 552:
      "Psionic Charm Monster"
    of 553:
      "Goblin Ballista Fireball"
    of 554:
      "Ioun Stone Power: Dusty Rose"
    of 555:
      "Ioun Stone Power: Pale Blue"
    of 556:
      "Ioun Stone Power: Scarlet Blue"
    of 557:
      "Ioun Stone Power: Blue"
    of 558:
      "Ioun Stone Power: Deep Red"
    of 559:
      "Ioun Stone Power: Pink"
    of 560:
      "Ioun Stone Power: Pink Green"
    of 561:
      "Whirlwind Attack"
    of 562:
      "Aura of Glory - Cursed"
    of 563:
      "Haste-Slow"
    of 564:
      "Create ShadowFiend"
    of 565:
      "Tide of Battle"
    of 566:
      "Evil Blight"
    of 567:
      "Cure Critical Wounds - Others"
    of 568:
      "Restoration - Other"
    of 569:
      "Cloud of Bewilderment"
    of 600:
      "Imbue Arrow"
    of 601:
      "Seeker Arrow I"
    of 602:
      "Seeker Arrow II"
    of 603:
      "Hail of Arrows"
    of 604:
      "Arrow of Death"
    of 605:
      "Ghostly Visage"
    of 606:
      "Darkness"
    of 607:
      "Invisibility"
    of 608:
      "Improved Invisibility"
    of 609:
      "Create Undead"
    of 610:
      "Lesser Planar Binding"
    of 611:
      "Inflict Serious Wounds"
    of 612:
      "Inflict Critical Wounds"
    of 613:
      "Contagion"
    of 614:
      "Bull's Strength"
    of 615:
      "Flame Twin"
    of 616:
      "Lyrics of the Lich"
    of 617:
      "Iceberry"
    of 618:
      "Flameberry"
    of 619:
      "Transmogrifying Wand"
    of 620:
      "Flying Debris"
    of 622:
      "Divine Wrath"
    of 623:
      "Animate Dead"
    of 624:
      "Summon Undead"
    of 625:
      "Undead Graft I"
    of 626:
      "Undead Graft II"
    of 627:
      "Summon Greater Undead"
    of 628:
      "Deathless Master Touch"
    of 636:
      "Epic Spell: Hellball"
    of 637:
      "Epic Spell: Mummy Dust"
    of 638:
      "Epic Spell: Dragon Knight"
    of 639:
      "Epic Spell: Epic Mage Armor"
    of 640:
      "Epic Spell: Greater Ruin"
    of 641:
      "Defensive Stance"
    of 642:
      "Mighty Rage"
    of 643:
      "Planar Turning"
    of 644:
      "Curse Song"
    of 645:
      "Improved Whirlwind Attack"
    of 646:
      "Greater Wildshape I (wyrmling shape)"
    of 647:
      "Blinding Speed"
    of 648:
      "Dye: Cloth 1"
    of 649:
      "Dye: Cloth 2"
    of 650:
      "Dye: Leather 1"
    of 651:
      "Dye: Leather 2"
    of 652:
      "Dye: Metal 1"
    of 653:
      "Dye: Metal 2"
    of 654:
      "Add Item Property"
    of 655:
      "Poison Weapon"
    of 656:
      "Craft Weapon"
    of 657:
      "Craft Armor"
    of 658:
      "Wyrmling, Red"
    of 659:
      "Wyrmling, Blue"
    of 660:
      "Wyrmling, Black"
    of 661:
      "Wyrmling, White"
    of 662:
      "Wyrmling, Green"
    of 663:
      "Wyrmling Breath, Cold"
    of 664:
      "Wyrmling Breath, Acid"
    of 665:
      "Wyrmling Breath, Fire"
    of 666:
      "Wyrmling Breath, Gas"
    of 667:
      "Wyrmling Breath, Lightning"
    of 668:
      "Teleport Projectile Properties"
    of 669:
      "Chaos Shield (2% chance to strike on attacker)"
    of 670:
      "Basilisk"
    of 671:
      "Beholder"
    of 672:
      "Harpy"
    of 673:
      "Drider"
    of 674:
      "Manticore"
    of 675:
      "Greater Wildshape II"
    of 676:
      "Greater Wildshape III"
    of 677:
      "Greater Wildshape IV"
    of 678:
      "Gargoyle"
    of 679:
      "Medusa"
    of 680:
      "Minotaur"
    of 681:
      "Humanoid Shape"
    of 682:
      "Drow Warrior"
    of 683:
      "Lizardfolk Whipmaster"
    of 684:
      "Kobold Commando"
    of 685:
      "Undead Shape"
    of 686:
      "Captivating Song"
    of 687:
      "Gaze, Petrification"
    of 688:
      "Darkness"
    of 689:
      "Blessed Bolt Properties (Slay Rakshasa)"
    of 690:
      "Dragon Breath"
    of 691:
      "Mindflayer"
    of 692:
      "Manticore Spikes"
    of 693:
      "Illithid Mind Blast"
    of 694:
      "Large Dire Tiger"
    of 695:
      "Epic Spell: Epic Warding"
    of 696:
      "Flaming Weapon Properties (Fire Damage)"
    of 697:
      "Activate Item (Long Range)"
    of 698:
      "Dragonbreath, Negative Energy"
    of 700:
      "Unique Power (OnHit)"
    of 701:
      "Summon Baatezu"
    of 702:
      "Planar Rift Properties (Black Blade of Disaster)"
    of 703:
      "Dark Fire (Immolate)"
    of 704:
      "Risen Lord"
    of 705:
      "Vampire"
    of 706:
      "Spectre"
    of 707:
      "Ancient Red Dragon"
    of 708:
      "Ancient Blue Dragon"
    of 709:
      "Ancient Green Dragon"
    of 710:
      "Eyeball Frost Ray Attack"
    of 711:
      "Eyeball Inflict Wounds Ray"
    of 712:
      "Eyeball Flame Ray Attack"
    of 713:
      "Psionic Mind Blast 10m Radius"
    of 714:
      "Psionic Mind Blast (Paragon)"
    of 715:
      "Golem Slam"
    of 716:
      "Extract Brain"
    of 717:
      "Sequencer (1 spell)"
    of 718:
      "Sequencer (2 spells)"
    of 719:
      "Sequencer (3 spells)"
    of 720:
      "Clear Sequencer"
    of 721:
      "Flaming Hide"
    of 724:
      "Etherealness"
    of 725:
      "Dragon Shape"
    of 727:
      "Beholder Antimagic Cone"
    of 731:
      "Bebilith Web"
    of 732:
      "Outsider Shape"
    of 733:
      "Azer Chieftain"
    of 734:
      "Rakshasa"
    of 735:
      "Death Slaad Lord"
    of 736:
      "Beholder Special Attacks"
    of 737:
      "Construct Shape"
    of 738:
      "Stone Golem"
    of 739:
      "Demonflesh Golem"
    of 740:
      "Iron Golem"
    of 741:
      "Psionic Inertial Barrier"
    of 742:
      "Craft Weapon Component"
    of 743:
      "Craft Armor Component"
    of 744:
      "Firebomb"
    of 745:
      "Acidbomb"
    of 756:
      "Ruin Armor (Bebilith)"
    of 757:
      "Shadowblend"
    of 758:
      "Paralyzing Touch (Demilich)"
    of 759:
      "Harm Self (Undead)"
    of 760:
      "Paralyzing Touch (Dracolich)"
    of 761:
      "Aura of Hellfire"
    of 762:
      "Hell Inferno"
    of 763:
      "Psionic Mass Concussion"
    of 767:
      "Talk to"
    of 768:
      "Intelligent Weapon"
    of 769:
      "Shadow attack"
    of 770:
      "Chaos Spittle"
    of 771:
      "Dragon Breath, Prismatic"
    of 773:
      "Hurl Rocks"
    of 774:
      "Deflecting Force"
    of 775:
      "Hurl Rocks"
    of 776:
      "Beholder Special Attacks"
    of 777:
      "Beholder Special Attacks"
    of 778:
      "Beholder Special Attacks"
    of 779:
      "Beholder Special Attacks"
    else:
      "Unknown"
