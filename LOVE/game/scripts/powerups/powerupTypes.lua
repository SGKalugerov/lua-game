local effects = {
    ["Splitshot"] = 1,
    ["Damage"] = 2,
    ["Speed"] = 3,
    ["Highjump"] = 4,
    ["Laser"] = 5
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
        spritePath = 'assets/powerups/splitshot.png',
        rateOfFire = 0.35,
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
        effect = effects['Laser'],
        duration = 99999,
        category = category['Weapon'],
        spritePath = 'assets/powerups/laser.png',
        effectSpritePath = 'assets/weapons/laser.png',
        rateOfFire = 0.7
    }

}


return {
    effects = effects,
    category = category,
    powerups = powerups
}
