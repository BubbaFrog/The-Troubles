minetest.register_on_dieplayer(function(player)
    local pname = player:get_player_name()
    local pos = player:getpos()
    pos.x = math.floor(pos.x)
    pos.y = math.floor(pos.y)
    pos.z = math.floor(pos.z)

    minetest.chat_send_player(pname, core.get_color_escape_sequence("#FF0000") .."*** Server - Last Dead At: " .. pos.x .. ", " .. pos.y .. ", " .. pos.z )

		music = minetest.sound_play("death",
{  loop = false,
   gain = 1.0,
		})


end)
