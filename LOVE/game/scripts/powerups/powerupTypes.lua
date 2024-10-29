local effects = {
    ["Multishot"] = 1,
    ["Speed"] = 2,
    ["Damage"] = 3
}
local category = {
    ["Buff"] = 1,
    ["Weapon"] = 2
}
local powerups = {
    [1] = {
        effect = effects['Multishot'],
        duration = 99999,
        category = category['Weapon']
    },
    [2] = {
        effect = effects['Damage'],
        duration = 30,
        category = category['Buff'],
        value = 2
    },
    [3] = {
        effect = effects['Speed'],
        duration = 60,
        category = category['Buff'],
        value = 1.4
    },
    [4] = {
        effect = effects['Laser'],
        duration = 99999,
        category = category['Weapon']
    },
    [5] = {
        effect = effects['Flamethrower'],
        duration = 99999,
        category = category['Weapon']
    }

}


return {
    effects = effects,
    category = category,
    powerups = powerups
}
