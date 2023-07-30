-- Copyright (C) 2019 Bernd Lachner <dev@lachner-net.de>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

-- Count the number of pictures.
local function get_picture(number)
    local filename	= minetest.get_modpath("gallery").."/textures/picture_"..number..".png"
    local file		= io.open(filename, "r")
    if file ~= nil then 
        io.close(file) 
        return true 
    else 
        return false 
    end
end

local function get_pngwidthheight(number)
    local width,height=0,0
    local filename = minetest.get_modpath("gallery").."/textures/picture_"..number..".png"
    local file=io.open(filename,"rb")
    if file ~= nil then
        file:seek("set",1)
        if file:read(3)=="PNG" then
            file:seek("set",12)
            if file:read(4)=="IHDR" then
                local widthstr,heightstr=file:read(4),file:read(4)
                width=widthstr:sub(1,1):byte()*16777216+widthstr:sub(2,2):byte()*65536+widthstr:sub(3,3):byte()*256+widthstr:sub(4,4):byte()
                height=heightstr:sub(1,1):byte()*16777216+heightstr:sub(2,2):byte()*65536+heightstr:sub(3,3):byte()*256+heightstr:sub(4,4):byte()
            end
        end                
        io.close(file)
    end
    return width,height
end
    
local N = 1

while get_picture(N) == true do
    N = N + 1
end

N = N - 1

-- register for each picture
for n=1, N do

    local groups = {choppy=2, dig_immediate=3, picture=1, not_in_creative_inventory=1}
    if n == 1 then
        groups = {choppy=2, dig_immediate=3, picture=1}
    end

    -- Texture for the frame
    local frame_texture = "metal.png"
    -- Pixel size of the resulting texture for the node. Higher resolutions for more details.
    local resulttexture_pix = 800
    -- Frame border width in percent
    local frame_widthpercent = 2.5
    -- Scaling of the picture
    local pic_scale = 2.5

    -- Get the width and height of the picture from the file in pixel
    local pic_pixwidth,pic_pixheight=get_pngwidthheight(n)
    -- Get the max side lenght of the picture in pixel
    local pic_pixmax = math.max(pic_pixwidth,pic_pixheight)
    -- Frame border width in pixel
    local frame_widthpixel = math.ceil(frame_widthpercent * pic_pixmax / 100.0)

    -- Distance beetween the frame and the picture in pixel
    local border_pix = 4
    -- Pixel size of the combined square texture of the picture with frame and border
    local pictexture_pix = pic_pixmax + (frame_widthpixel * 2) + (border_pix * 2)
    -- X and Y position oft the picture in the combined square texture of the picture with frame and border
    local pic_xoffset = ((pic_pixmax - pic_pixwidth) / 2) + frame_widthpixel + border_pix
    local pic_yoffset = ((pic_pixmax - pic_pixheight) / 2) + frame_widthpixel + border_pix

    -- Frame border width of the node
    local frame_widthnode = 1.0 / pictexture_pix * frame_widthpixel
    -- Frame border thickness of the node
    local frame_thickness = 0.1

    -- Picture width of the node (whole picture including frame)
    local pic_width = 1.0
    -- Picture height of the node (whole picture including frame)
    local pic_height = 1.0
    -- Picture thickness of the node
    local pic_thickness = 0.05

    if pic_pixwidth > pic_pixheight then
        -- Landscape picture. Set the Picture height of the node (whole picture including frame) accordingly to the original picture aspect ratio
        pic_height = (pic_width / pictexture_pix) * (pic_pixheight + 2 * (frame_widthpixel + border_pix))
    else
        -- Potrait picture Set the Picture width of the node (whole picture including frame) accordingly to the original picture aspect ratio
        pic_width = (pic_height / pictexture_pix) * (pic_pixwidth + 2 * (frame_widthpixel + border_pix))
    end

    -- node
    minetest.register_node("gallery:node_"..n.."", {
        description = "Picture #"..n.."",
        drawtype = "nodebox",
         -- Tile definition in the follwing order: +Y, -Y, +X, -X, +Z, -Z. 
        tiles = {
            {name="("..frame_texture.."^[resize:"..resulttexture_pix.."x"..resulttexture_pix..")^([combine:"..pictexture_pix.."x"..pictexture_pix..":"..pic_xoffset..","..pic_yoffset.."=picture_"..n..".png^[resize:"..resulttexture_pix.."x"..resulttexture_pix..")"}, 
            {name=frame_texture}
        },
        visual_scale = pic_scale,
        inventory_image = "gallery_inventory.png",
        wield_image = "gallery_inventory.png",
        paramtype = "light",
        paramtype2 = "wallmounted",
        sunlight_propagates = true,
        walkable = false,
        node_box = {
            type = "fixed",
            -- Box definition in following order: {x1, y1, z1, x2, y2, z2}
            fixed = {
                -- Picture
                {-pic_width/2.0, -0.5/pic_scale, -pic_height/2.0, pic_width/2.0, -(0.5 - pic_thickness) / pic_scale, pic_height/2.0},                   
                -- Left frame border
                {-pic_width/2.0, -0.5/pic_scale, -pic_height/2.0, -pic_width/2.0+frame_widthnode, -(0.5 - frame_thickness) / pic_scale, pic_height/2.0},
                -- Right frame border
                {pic_width/2.0-frame_widthnode, -0.5/pic_scale, -pic_height/2.0, pic_width/2.0, -(0.5 - frame_thickness) / pic_scale, pic_height/2.0},
                 -- Bottom frame border
                {-pic_width/2.0, -0.5/pic_scale, -pic_height/2.0, pic_width/2.0, -(0.5 - frame_thickness) / pic_scale, -pic_height/2.0+frame_widthnode},
                -- Top frame border
                {-pic_width/2.0, -0.5/pic_scale, pic_height/2.0-frame_widthnode, pic_width/2.0, -(0.5 - frame_thickness) / pic_scale, pic_height/2.0},
            },
        },
        selection_box = {
            type = "wallmounted",
        },
        groups = groups,

        on_rightclick = function(pos, node, clicker)
            local length = string.len (node.name)
            local number = string.sub (node.name, 14, length)
            
            -- TODO. Reducing currently not working, because sneaking prevents right click.
            local keys=clicker:get_player_control()
            if keys["sneak"]==false then
                if number == tostring(N) then
                    number = 1
                else
                    number = number + 1
                end
            else
                if number == 1 then
                    number = N - 1
                else
                    number = number - 1
                end
            end

            print("[gallery] number is "..number.."")
            node.name = "gallery:node_"..number..""
            minetest.env:set_node(pos, node)
        end

        --	TODO.
        --	on_place = minetest.rotate_node
    })

    -- crafts
    if n < N then
        minetest.register_craft({
            output = 'gallery:node_'..n..'',
            recipe = {
                {'gallery:node_'..(n+1)..''},
            }
        })
    end

    n = n + 1

end

-- close the craft loop
minetest.register_craft({
    output = 'gallery:node_'..N..'',
    recipe = {
        {'gallery:node_1'},
    }
})

-- initial craft
minetest.register_craft({
    output = 'gallery:node_1',
    recipe = {
        {'default:paper', 'default:paper'},
        {'default:paper', 'default:paper'},
        {'default:paper', 'default:paper'},
    }
})

-- reset several pictures to #1
minetest.register_craft({
    type = 'shapeless',
    output = 'gallery:node_1 2',
    recipe = {'group:picture', 'group:picture'},
})

minetest.register_craft({
    type = 'shapeless',
    output = 'gallery:node_1 3',
    recipe = {'group:picture', 'group:picture', 'group:picture'},
})

minetest.register_craft({
    type = 'shapeless',
    output = 'gallery:node_1 4',
    recipe = {
        'group:picture', 'group:picture', 'group:picture', 
        'group:picture'
    }
})

minetest.register_craft({
    type = 'shapeless',
    output = 'gallery:node_1 5',
    recipe = {
        'group:picture', 'group:picture', 'group:picture', 
        'group:picture', 'group:picture'
    }
})

minetest.register_craft({
    type = 'shapeless',
    output = 'gallery:node_1 6',
    recipe = {
        'group:picture', 'group:picture', 'group:picture', 
        'group:picture', 'group:picture', 'group:picture'
    }
})

minetest.register_craft({
    type = 'shapeless',
    output = 'gallery:node_1 7',
    recipe = {
        'group:picture', 'group:picture', 'group:picture', 
        'group:picture', 'group:picture', 'group:picture', 
        'group:picture'
    }
})

minetest.register_craft({
    type = 'shapeless',
    output = 'gallery:node_1 8',
    recipe = {
        'group:picture', 'group:picture', 'group:picture', 
        'group:picture', 'group:picture', 'group:picture', 
        'group:picture', 'group:picture'
    }
})

minetest.register_craft({
    type = 'shapeless',
    output = 'gallery:node_1 9',
    recipe = {
        'group:picture', 'group:picture', 'group:picture', 
        'group:picture', 'group:picture', 'group:picture', 
        'group:picture', 'group:picture', 'group:picture'
    }
})
