-- Helper utility to generate quads
require '/lib/quads'

local iconTexture = love.graphics.newImage('images/icons.png')
iconTexture:setFilter('nearest','nearest')

local iconMap = {
    ['pause'] = 33,
    ['play'] = 34,
    ['zzz'] = 17,
    ['meh'] = 11,
    ['ok'] = 10,
    ['dealwithit'] = 23
}

local iconQuads = GenerateQuads(iconTexture, 16, 16)

function getIconQuads(name)
    return iconQuads[iconMap[name]]
end

function getIconTexture()
    return iconTexture
end