local effects = {
    ["Splitshot"] = 1,
    ["Damage"] = 2,
    ["Speed"] = 3,
    ["Highjump"] = 4,
}
local category = {
    ["Buff"] = 1,
    ["Weapon"] = 2
}
local powerups = {
    [1] = {
        effect = effects['Splitshot'],
        duration = 99999,
        category = category['Weapon'],
        spritePath = 'assets/weapons/splitshot.png'
    },
    [2] = {
        effect = effects['Damage'],
        duration = 30,
        category = category['Buff'],
        value = 2
    },
    [3] = {
        effect = effects['Speed'],
        duration = 30,
        category = category['Buff'],
        value = 1.4
    },
    [4] = {
        effect = effects['Highjump'],
        duration = 30,
        category = category['Buff'],
        value = 1.4
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
