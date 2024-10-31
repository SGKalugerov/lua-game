local MapManager = {}
local json = require "utils.dkjson"

MapManager.collidableTiles = {}

function MapManager:loadMap(mapFile, tilesetData)
    local mapData = self:loadJSON(mapFile)
    self.tileWidth = mapData.tilewidth
    self.tileHeight = mapData.tileheight
    self.mapWidth = mapData.width
    self.mapHeight = mapData.height
    self.layers = mapData.layers
    self:processTileset(tilesetData)
end

function MapManager:loadJSON(filename)
    local content, size = love.filesystem.read(filename)
    if not content then error("Could not open file " .. filename) end

    local decoded, pos, err = json.decode(content, 1, nil)
    if err then error("Error parsing JSON: " .. err) end
    return decoded
end

function MapManager:processTileset(tilesetData)
    for _, tile in ipairs(tilesetData.tiles) do
        if tile.properties and tile.properties.collidable == true then
            self.collidableTiles[tile.id] = true
        end
    end
end

function MapManager:isCollidable(tileID)
    return self.collidableTiles[tileID] or false
end

function MapManager:drawMap(tileImages)
    for _, layer in ipairs(self.layers) do
        if layer.type == "tilelayer" then
            for y = 1, self.mapHeight do
                for x = 1, self.mapWidth do
                    local tileID = layer.data[(y - 1) * self.mapWidth + x]
                    local tileImage = tileImages[tileID]
                    if tileImage then
                        love.graphics.draw(tileImage, (x) * self.tileWidth, (y - 1) * self.tileHeight)
                    end
                end
            end
        end
    end
end

return MapManager
