SpelllistSettings = {
    ['Default'] = {
        iconFile = '/images/game/spells/spell-icons-32x32',
        iconsForGameCooldown = '/images/game/spells/spell-icons-20x20',
        iconSize = {
            width = 32,
            height = 32
        },
        iconSizeCooldown = {
            width = 20,
            height = 22
        },
        spellListWidth = 210,
        spellWindowWidth = 550,
    } --[[,
['Custom'] =  {
  iconFile = '/images/game/spells/custom',
  iconSize = {width = 32, height = 32},
  spellOrder = {
    'Chain Lighting'
    ,'Chain Healing'
    ,'Divine Chain'
    ,'Berserk Chain'
    ,'Cheat death'
    ,'Brutal Charge'
    ,'Empower Summons'
    ,'Summon Doppelganger'
  }
}]]
}

-- Mubia: las magias de Tibia se quitaron; aquí van las magias MU del servidor (data/libs/systems/mubia.lua)
SpellInfo = {
    Default = {
        -- Mubia: solo magias MU (vocaciones del cliente: DK 4/8, DW 1/5, Elf 3/7). Iconos provisorios.
        -- Deben coincidir con Mubia.SpellList del servidor (data/libs/systems/mubia.lua).
        -- Dark Knight / Blade Knight
        ['Twisting Slash'] = { id = 300, name = 'Twisting Slash', words = 'twisting slash', type = 'Instant', level = 1, mana = 10, soul = 0, maglevel = 0, icon = '', clientId = 18, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {4, 8, 11}, special = false, source = 0, },
        ['Impale'] = { id = 305, name = 'Impale', words = 'impale', type = 'Instant', level = 1, mana = 8, soul = 0, maglevel = 0, icon = '', clientId = 111, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {4, 8, 11}, special = false, source = 0, },
        ['Swell Life'] = { id = 306, name = 'Swell Life', words = 'swell life', type = 'Instant', level = 1, mana = 22, soul = 0, maglevel = 0, icon = '', clientId = 133, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {4, 8}, special = false, source = 0, },
        ['Death Stab'] = { id = 307, name = 'Death Stab', words = 'death stab', type = 'Instant', level = 1, mana = 15, soul = 0, maglevel = 0, icon = '', clientId = 61, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 2, exhaustion = 1000, premium = false, vocations = {4, 8}, special = false, source = 0, },
        ['Rageful Blow'] = { id = 308, name = 'Rageful Blow', words = 'rageful blow', type = 'Instant', level = 1, mana = 25, soul = 0, maglevel = 0, icon = '', clientId = 106, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {4, 8}, special = false, source = 0, },
        ['Strike of Destruction'] = { id = 309, name = 'Strike of Destruction', words = 'strike of destruction', type = 'Instant', level = 1, mana = 30, soul = 0, maglevel = 0, icon = '', clientId = 112, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 4, exhaustion = 1000, premium = false, vocations = {4, 8}, special = false, source = 0, },
        -- Dark Wizard / Soul Master
        ['Energy Ball'] = { id = 302, name = 'Energy Ball', words = 'energy ball', type = 'Instant', level = 1, mana = 1, soul = 0, maglevel = 0, icon = '', clientId = 28, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Fire Ball'] = { id = 310, name = 'Fire Ball', words = 'fire ball', type = 'Instant', level = 1, mana = 3, soul = 0, maglevel = 0, icon = '', clientId = 89, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Power Wave'] = { id = 311, name = 'Power Wave', words = 'power wave', type = 'Instant', level = 1, mana = 5, soul = 0, maglevel = 0, icon = '', clientId = 13, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Lightning'] = { id = 312, name = 'Lightning', words = 'lightning', type = 'Instant', level = 1, mana = 15, soul = 0, maglevel = 0, icon = '', clientId = 149, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Teleport'] = { id = 313, name = 'Teleport', words = 'teleport', type = 'Instant', level = 1, mana = 30, soul = 0, maglevel = 0, icon = '', clientId = 81, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {1, 5}, special = false, source = 0, },
        ['Meteorite'] = { id = 314, name = 'Meteorite', words = 'meteorite', type = 'Instant', level = 1, mana = 12, soul = 0, maglevel = 0, icon = '', clientId = 24, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Ice'] = { id = 315, name = 'Ice', words = 'ice', type = 'Instant', level = 1, mana = 38, soul = 0, maglevel = 0, icon = '', clientId = 112, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Poison'] = { id = 316, name = 'Poison', words = 'poison', type = 'Instant', level = 1, mana = 42, soul = 0, maglevel = 0, icon = '', clientId = 142, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Flame'] = { id = 317, name = 'Flame', words = 'flame', type = 'Instant', level = 1, mana = 50, soul = 0, maglevel = 0, icon = '', clientId = 138, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Twister'] = { id = 318, name = 'Twister', words = 'twister', type = 'Instant', level = 1, mana = 60, soul = 0, maglevel = 0, icon = '', clientId = 107, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Evil Spirit'] = { id = 301, name = 'Evil Spirit', words = 'evil spirit', type = 'Instant', level = 1, mana = 40, soul = 0, maglevel = 0, icon = '', clientId = 37, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Hellfire'] = { id = 319, name = 'Hellfire', words = 'hellfire', type = 'Instant', level = 1, mana = 160, soul = 0, maglevel = 0, icon = '', clientId = 19, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Aqua Beam'] = { id = 320, name = 'Aqua Beam', words = 'aqua beam', type = 'Instant', level = 1, mana = 140, soul = 0, maglevel = 0, icon = '', clientId = 22, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Cometfall'] = { id = 321, name = 'Cometfall', words = 'cometfall', type = 'Instant', level = 1, mana = 90, soul = 0, maglevel = 0, icon = '', clientId = 119, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Inferno'] = { id = 322, name = 'Inferno', words = 'inferno', type = 'Instant', level = 1, mana = 200, soul = 0, maglevel = 0, icon = '', clientId = 24, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {1, 5, 11}, special = false, source = 0, },
        ['Soul Barrier'] = { id = 323, name = 'Soul Barrier', words = 'soul barrier', type = 'Instant', level = 1, mana = 70, soul = 0, maglevel = 0, icon = '', clientId = 44, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {1, 5}, special = false, source = 0, },
        ['Ice Storm'] = { id = 324, name = 'Ice Storm', words = 'ice storm', type = 'Instant', level = 1, mana = 100, soul = 0, maglevel = 0, icon = '', clientId = 118, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {1, 5}, special = false, source = 0, },
        ['Decay'] = { id = 325, name = 'Decay', words = 'decay', type = 'Instant', level = 1, mana = 110, soul = 0, maglevel = 0, icon = '', clientId = 113, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {1, 5}, special = false, source = 0, },
        -- Fairy Elf / Muse Elf
        ['Multi-Shot'] = { id = 303, name = 'Multi-Shot', words = 'multi shot', type = 'Instant', level = 1, mana = 10, soul = 0, maglevel = 0, icon = '', clientId = 17, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Penetration'] = { id = 304, name = 'Penetration', words = 'penetration', type = 'Instant', level = 1, mana = 9, soul = 0, maglevel = 0, icon = '', clientId = 58, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Heal'] = { id = 326, name = 'Heal', words = 'heal', type = 'Instant', level = 1, mana = 20, soul = 0, maglevel = 0, icon = '', clientId = 1, group = { [2] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Greater Defense'] = { id = 327, name = 'Greater Defense', words = 'greater defense', type = 'Instant', level = 1, mana = 30, soul = 0, maglevel = 0, icon = '', clientId = 132, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Greater Damage'] = { id = 328, name = 'Greater Damage', words = 'greater damage', type = 'Instant', level = 1, mana = 40, soul = 0, maglevel = 0, icon = '', clientId = 135, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Summon Goblin'] = { id = 329, name = 'Summon Goblin', words = 'summon goblin', type = 'Instant', level = 1, mana = 40, soul = 0, maglevel = 0, icon = '', clientId = 9, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Summon Stone Golem'] = { id = 330, name = 'Summon Stone Golem', words = 'summon stone golem', type = 'Instant', level = 1, mana = 70, soul = 0, maglevel = 0, icon = '', clientId = 9, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Summon Assassin'] = { id = 331, name = 'Summon Assassin', words = 'summon assassin', type = 'Instant', level = 1, mana = 110, soul = 0, maglevel = 0, icon = '', clientId = 9, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Summon Elite Yeti'] = { id = 332, name = 'Summon Elite Yeti', words = 'summon elite yeti', type = 'Instant', level = 1, mana = 160, soul = 0, maglevel = 0, icon = '', clientId = 9, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Summon Dark Knight'] = { id = 333, name = 'Summon Dark Knight', words = 'summon dark knight', type = 'Instant', level = 1, mana = 200, soul = 0, maglevel = 0, icon = '', clientId = 9, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Summon Bali'] = { id = 334, name = 'Summon Bali', words = 'summon bali', type = 'Instant', level = 1, mana = 250, soul = 0, maglevel = 0, icon = '', clientId = 9, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Summon Soldier'] = { id = 335, name = 'Summon Soldier', words = 'summon soldier', type = 'Instant', level = 1, mana = 350, soul = 0, maglevel = 0, icon = '', clientId = 9, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Ice Arrow'] = { id = 336, name = 'Ice Arrow', words = 'ice arrow', type = 'Instant', level = 1, mana = 10, soul = 0, maglevel = 0, icon = '', clientId = 121, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Recovery'] = { id = 337, name = 'Recovery', words = 'recovery', type = 'Instant', level = 1, mana = 40, soul = 0, maglevel = 0, icon = '', clientId = 159, group = { [2] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Focus Shot'] = { id = 338, name = 'Focus Shot', words = 'focus shot', type = 'Instant', level = 1, mana = 20, soul = 0, maglevel = 0, icon = '', clientId = 57, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        ['Starfall'] = { id = 339, name = 'Starfall', words = 'starfall', type = 'Instant', level = 1, mana = 30, soul = 0, maglevel = 0, icon = '', clientId = 122, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {3, 7}, special = false, source = 0, },
        -- Magic Gladiator (ademas de las de DK y DW que llevan el 11)
        ['Fire Slash'] = { id = 340, name = 'Fire Slash', words = 'fire slash', type = 'Instant', level = 1, mana = 20, soul = 0, maglevel = 0, icon = '', clientId = 89, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 2, exhaustion = 1000, premium = false, vocations = {11}, special = false, source = 0, },
        ['Spiral Slash'] = { id = 341, name = 'Spiral Slash', words = 'spiral slash', type = 'Instant', level = 1, mana = 25, soul = 0, maglevel = 0, icon = '', clientId = 18, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {11}, special = false, source = 0, },
        ['Flame Strike'] = { id = 342, name = 'Flame Strike', words = 'flame strike', type = 'Instant', level = 1, mana = 35, soul = 0, maglevel = 0, icon = '', clientId = 106, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {11}, special = false, source = 0, },
        ['Gigantic Storm'] = { id = 343, name = 'Gigantic Storm', words = 'gigantic storm', type = 'Instant', level = 1, mana = 120, soul = 0, maglevel = 0, icon = '', clientId = 118, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {11}, special = false, source = 0, },
        ['Mana Rays'] = { id = 344, name = 'Mana Rays', words = 'mana rays', type = 'Instant', level = 1, mana = 130, soul = 0, maglevel = 0, icon = '', clientId = 13, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {11}, special = false, source = 0, },
        -- Dark Lord
        ['Force'] = { id = 350, name = 'Force', words = 'force', type = 'Instant', level = 1, mana = 10, soul = 0, maglevel = 0, icon = '', clientId = 28, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 4, exhaustion = 1000, premium = false, vocations = {12}, special = false, source = 0, },
        ['Fire Burst'] = { id = 351, name = 'Fire Burst', words = 'fire burst', type = 'Instant', level = 1, mana = 25, soul = 0, maglevel = 0, icon = '', clientId = 89, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {12}, special = false, source = 0, },
        ['Fire Scream'] = { id = 352, name = 'Fire Scream', words = 'fire scream', type = 'Instant', level = 1, mana = 45, soul = 0, maglevel = 0, icon = '', clientId = 106, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {12}, special = false, source = 0, },
        ['Electric Spark'] = { id = 353, name = 'Electric Spark', words = 'electric spark', type = 'Instant', level = 1, mana = 50, soul = 0, maglevel = 0, icon = '', clientId = 149, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {12}, special = false, source = 0, },
        ['Earthshake'] = { id = 354, name = 'Earthshake', words = 'earthshake', type = 'Instant', level = 1, mana = 40, soul = 0, maglevel = 0, icon = '', clientId = 19, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {12}, special = false, source = 0, },
        ['Chaotic Diseier'] = { id = 355, name = 'Chaotic Diseier', words = 'chaotic diseier', type = 'Instant', level = 1, mana = 60, soul = 0, maglevel = 0, icon = '', clientId = 37, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {12}, special = false, source = 0, },
        ['Critical Damage'] = { id = 356, name = 'Critical Damage', words = 'critical damage', type = 'Instant', level = 1, mana = 50, soul = 0, maglevel = 0, icon = '', clientId = 159, group = { [2] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {12}, special = false, source = 0, },
        -- Summoner / Bloody Summoner
        ['Drain Life'] = { id = 360, name = 'Drain Life', words = 'drain life', type = 'Instant', level = 1, mana = 50, soul = 0, maglevel = 0, icon = '', clientId = 37, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {13, 14}, special = false, source = 0, },
        ['Chain Lightning'] = { id = 361, name = 'Chain Lightning', words = 'chain lightning', type = 'Instant', level = 1, mana = 85, soul = 0, maglevel = 0, icon = '', clientId = 149, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {13, 14}, special = false, source = 0, },
        ['Lightning Shock'] = { id = 362, name = 'Lightning Shock', words = 'lightning shock', type = 'Instant', level = 1, mana = 115, soul = 0, maglevel = 0, icon = '', clientId = 119, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {13, 14}, special = false, source = 0, },
        ['Explosion'] = { id = 363, name = 'Explosion', words = 'explosion', type = 'Instant', level = 1, mana = 90, soul = 0, maglevel = 0, icon = '', clientId = 24, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {13, 14}, special = false, source = 0, },
        ['Requiem'] = { id = 364, name = 'Requiem', words = 'requiem', type = 'Instant', level = 1, mana = 110, soul = 0, maglevel = 0, icon = '', clientId = 37, group = { [1] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {13, 14}, special = false, source = 0, },
        ['Pollution'] = { id = 365, name = 'Pollution', words = 'pollution', type = 'Instant', level = 1, mana = 120, soul = 0, maglevel = 0, icon = '', clientId = 142, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {13, 14}, special = false, source = 0, },
        ['Sleep'] = { id = 366, name = 'Sleep', words = 'sleep', type = 'Instant', level = 1, mana = 20, soul = 0, maglevel = 0, icon = '', clientId = 44, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {13, 14}, special = false, source = 0, },
        ['Weakness'] = { id = 367, name = 'Weakness', words = 'weakness', type = 'Instant', level = 1, mana = 50, soul = 0, maglevel = 0, icon = '', clientId = 132, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {13, 14}, special = false, source = 0, },
        ['Innovation'] = { id = 368, name = 'Innovation', words = 'innovation', type = 'Instant', level = 1, mana = 70, soul = 0, maglevel = 0, icon = '', clientId = 135, group = { [1] = 1000 }, needTarget = true, parameter = false, range = 5, exhaustion = 1000, premium = false, vocations = {13, 14}, special = false, source = 0, },
        ['Berserker'] = { id = 369, name = 'Berserker', words = 'berserker', type = 'Instant', level = 1, mana = 100, soul = 0, maglevel = 0, icon = '', clientId = 133, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {13, 14}, special = false, source = 0, },
        ['Damage Reflection'] = { id = 370, name = 'Damage Reflection', words = 'damage reflection', type = 'Instant', level = 1, mana = 40, soul = 0, maglevel = 0, icon = '', clientId = 44, group = { [3] = 1000 }, needTarget = false, parameter = false, range = -1, exhaustion = 1000, premium = false, vocations = {13, 14}, special = false, source = 0, },
    }
}

VocationNames = {
    [0] = 'None',
    [1] = 'Sorcerer',
    [2] = 'Druid',
    [3] = 'Paladin',
    [4] = 'Knight',
    [5] = 'Master Sorcerer',
    [6] = 'Elder Druid',
    [7] = 'Royal Paladin',
    [8] = 'Elite Knight',
    [9] = 'Monk',
    [10] = 'Exalted Monk',
    [11] = 'Magic Gladiator',
    [12] = 'Dark Lord',
    [13] = 'Summoner',
    [14] = 'Bloody Summoner'
}

SpellGroups = {
    [1] = 'Attack',
    [2] = 'Healing',
    [3] = 'Support',
    [4] = 'Special',
    [5] = 'Conjure',
    [6] = 'Crippling',
    [7] = 'Focus',
    [8] = 'UltimateStrikes',
    [9] = 'GreatBeams',
    [10] = 'BurstsOfNature',
    [11] = 'Virtue'
}

SpellRunesData = {
    [3148] = {id = 30, group = 3, name = 'destroy field rune', exhaustion = 2000},
    [3149] = {id = 55, group = 1, name = 'energybomb rune', exhaustion = 2000},
    [3152] = {id = 4, group = 2, name = 'intense healing rune', exhaustion = 1000},
    [3153] = {id = 31, group = 2, name = 'antidote rune', exhaustion = 1000},
    [3155] = {id = 21, group = 1, name = 'sudden death rune', exhaustion = 2000},
    [3156] = {id = 94, group = 1, name = 'Wild Growth Rune', exhaustion = 2000},
    [3158] = {id = 114, group = 1, name = 'icicle rune', exhaustion = 2000},
    [3160] = {id = 5, group = 2, name = 'ultimate healing rune', exhaustion = 1000},
    [3161] = {id = 115, group = 1, name = 'avalanche rune', exhaustion = 2000},
    [3164] = {id = 27, group = 1, name = 'energy field rune', exhaustion = 2000},
    [3165] = {id = 54, group = 3, name = 'paralyze rune', exhaustion = 6000},
    [3166] = {id = 33, group = 1, name = 'energy wall rune', exhaustion = 2000},
    [3172] = {id = 26, group = 1, name = 'poison field rune', exhaustion = 2000},
    [3173] = {id = 91, group = 1, name = 'poison bomb rune', exhaustion = 2000},
    [3174] = {id = 7, group = 1, name = 'light magic missile rune', exhaustion = 2000},
    [3175] = {id = 116, group = 1, name = 'stone shower rune', exhaustion = 2000},
    [3176] = {id = 32, group = 1, name = 'poison wall rune', exhaustion = 2000},
    [3177] = {id = 12, group = 3, name = 'convince creature rune', exhaustion = 2000},
    [3178] = {id = 14, group = 3, name = 'chameleon rune', exhaustion = 2000},
    [3179] = {id = 77, group = 1, name = 'stalagmite rune', exhaustion = 2000},
    [3180] = {id = 86, group = 1, name = 'Magic Wall Rune', exhaustion = 2000},
    [3182] = {id = 130, group = 1, name = 'holy missile rune', exhaustion = 2000},
    [3188] = {id = 25, group = 1, name = 'fire field rune', exhaustion = 2000},
    [3189] = {id = 15, group = 1, name = 'fireball rune', exhaustion = 2000},
    [3190] = {id = 28, group = 1, name = 'fire wall rune', exhaustion = 2000},
    [3191] = {id = 16, group = 1, name = 'great fireball rune', exhaustion = 2000},
    [3192] = {id = 17, group = 1, name = 'firebomb rune', exhaustion = 2000},
    [3195] = {id = 50, group = 1, name = 'soulfire rune', exhaustion = 2000},
    [3197] = {id = 78, group = 3, name = 'desintegrate rune', exhaustion = 2000},
    [3198] = {id = 8, group = 1, name = 'heavy magic missile rune', exhaustion = 2000},
    [3200] = {id = 18, group = 1, name = 'explosion rune', exhaustion = 2000},
    [3202] = {id = 117, group = 1, name = 'thunderstorm rune', exhaustion = 2000},
    [3203] = {id = 83, group = 3, name = 'animate dead rune', exhaustion = 2000},
    [17512] = {id = 7, group = 1, name = 'lightest magic missile rune', exhaustion = 2000},
    [21351] = {id = 116, group = 1, name = 'light stone shower rune', exhaustion = 2000},
    [21352] = {id = 7, group = 1, name = 'lightest missile rune', exhaustion = 2000}
}

Spells = {}

function Spells.getSpellList()
    local spells = {}
    for k, spell in pairs(SpellInfo["Default"]) do
        table.insert(spells, spell)
    end
    return spells
end

function Spells.getSpellByName(name)
    return SpellInfo[Spells.getSpellProfileByName(name)][name]
end

function Spells.getSpellByWords(words)
    local words = words:lower():trim()
    for profile, data in pairs(SpellInfo) do
        for k, spell in pairs(data) do
            if spell.words == words then
                return spell, profile, k
            end
        end
    end
    return nil
end

function Spells.getSpellByIcon(iconId)
    for profile, data in pairs(SpellInfo) do
        for k, spell in pairs(data) do
            if spell.id == iconId then
                return spell, profile, k
            end
        end
    end
    return nil
end

function Spells.getSpellByClientId(clientId)
    for profile, data in pairs(SpellInfo) do
        for k, spell in pairs(data) do
            if spell.clientId == clientId then
                return spell, profile, k
            end
        end
    end
    return nil
end

function Spells.getSpellIconIds()
    local ids = {}
    for profile, data in pairs(SpellInfo) do
        for k, spell in pairs(data) do
            table.insert(ids, spell.id)
        end
    end
    return ids
end

function Spells.getSpellProfileById(id)
    for profile, data in pairs(SpellInfo) do
        for k, spell in pairs(data) do
            if spell.id == id then
                return profile
            end
        end
    end
    return nil
end

function Spells.getSpellProfileByWords(words)
    for profile, data in pairs(SpellInfo) do
        for k, spell in pairs(data) do
            if spell.words == words then
                return profile
            end
        end
    end
    return nil
end

function Spells.getSpellDataByWords(words)
    for profile, data in pairs(SpellInfo) do
        for k, spell in pairs(data) do
            if spell.words == words then
                return spell
            end
        end
    end
    return nil
end

function Spells.getSpellDataByParamWords(words)
    for profile, data in pairs(SpellInfo) do
        for k, spell in pairs(data) do
            local inputWords = words:lower()
            local spellWords = spell.words:lower()
            local quoteStartIndex = inputWords:find('%"')

            if not spell.parameter then
                if inputWords == spellWords then
                    return spell, nil
                end
            else
                if quoteStartIndex then
                    local spellPart = inputWords:sub(1, quoteStartIndex - 1):match("^%s*(.-)%s*$")
                    local parameter = inputWords:sub(quoteStartIndex + 1)
                    if spellPart == spellWords then
                        return spell, parameter
                    end
                else
                    if inputWords == spellWords then
                        return spell, nil
                    end
                end
            end
        end
    end
    return nil, nil
end

function Spells.getSpellFormatedName(words)
    for profile, data in pairs(SpellInfo) do
        for k, spell in pairs(data) do
            local inputWords = words:lower()
            local spellWords = spell.words:lower()

            if not spell.parameter then
                if inputWords == spellWords then
                    return spellWords
                end
            else
                if string.sub(inputWords, 1, string.len(spellWords)) == spellWords then
                    local extraText = string.sub(inputWords, string.len(spellWords) + 1)
                    if extraText ~= "" then
                        if string.sub(extraText, 1, 1) == " " then
                            local firstChar = string.sub(extraText, 2, 2)
                            if firstChar == '"' then
                                local fomated = extraText:gsub('"', '')
                                fomated = "\"" .. string.sub(fomated, 2) .. "\""
                                return spellWords .. " " .. fomated
                            else
                                return spellWords .. extraText
                            end
                        end
                    else
                        return spellWords
                    end
                end
            end
        end
    end
    return words
end

function Spells.getSpellNameByWords(words)
    for profile, data in pairs(SpellInfo) do
        for k, spell in pairs(data) do
            if spell.words == words then
                return k
            end
        end
    end
    return nil
end

function Spells.getSpellDataById(spellId)
    for _, data in pairs(SpellInfo) do
        for k, spell in pairs(data) do
            if spell.id == spellId then
                return spell
            end
        end
    end
    return nil
end

function Spells.getRuneSpellByItem(itemId)
    local data = SpellRunesData[itemId]
    if data then
        return data
    end
    return nil
end

function Spells.isRuneSpell(spellId)
    for _, data in pairs(SpellRunesData) do
        if data.id == spellId then
            return true
        end
    end
    return false
end

function Spells.getSpellProfileByName(spellName)
    for profile, data in pairs(SpellInfo) do
        if table.findbykey(data, spellName:trim(), true) then
            return profile
        end
    end
    return nil
end

function Spells.getSpellsByVocationId(vocId)
    local spells = {}
    for profile, data in pairs(SpellInfo) do
        for k, spell in pairs(data) do
            if table.contains(spell.vocations, vocId) then
                table.insert(spells, spell)
            end
        end
    end
    return spells
end

function Spells.filterSpellsByGroups(spells, groups)
    local filtered = {}
    for v, spell in pairs(spells) do
        local spellGroups = Spells.getGroupIds(spell)
        if table.equals(spellGroups, groups) then
            table.insert(filtered, spell)
        end
    end
    return filtered
end

function Spells.getCooldownByGroup(spellData, groupId)
    local keys = {}
    for k in pairs(spellData.group) do
        table.insert(keys, k)
    end
    table.sort(keys)
    local index = 1
    for _, k in ipairs(keys) do
        if index == 1 and k == groupId then
            return spellData.group[k]
        end
        index = index + 1
    end
    return nil
end

function Spells.getCooldownBySecondaryGroup(spellData, groupId)
    local keys = {}
    for k in pairs(spellData.group) do
        table.insert(keys, k)
    end
    table.sort(keys)
    local index = 1
    for _, k in ipairs(keys) do
        if index == 2 and k == groupId then
            return spellData.group[k]
        end
        index = index + 1
    end
    return nil
end

function Spells.getGroupIds(spell)
    local groups = {}
    for k, _ in pairs(spell.group) do
        table.insert(groups, k)
    end
    return groups
end

function Spells.getPrimaryGroup(spell)
    local indexes = {}
    for k in pairs(spell.group) do
        table.insert(indexes, k)
    end
    table.sort(indexes)
    return indexes[1] or -1
end

function Spells.getIconFileByProfile(profile)
    return SpelllistSettings[profile]['iconFile']
end

function Spells.getImageClip(indexClip, profile)
    if profile == nil then
        profile = "Default"
    end
    return indexClip * SpelllistSettings[profile].iconSize.width .. " 0 " .. SpelllistSettings[profile].iconSize.width .. " " .. SpelllistSettings[profile].iconSize.height
end

function Spells.getImageClipCooldown(indexClip, profile)
    if profile == nil then
        profile = "Default"
    end
    return indexClip * SpelllistSettings[profile].iconSizeCooldown.width .. " 0 " .. SpelllistSettings[profile].iconSizeCooldown.width .. " " .. SpelllistSettings[profile].iconSizeCooldown.height
end
