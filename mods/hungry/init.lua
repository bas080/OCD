--Simplest hunger mod ever by bas080
local hunger = {}
hunger.enabled = minetest.setting_getbool("enable_damage")
if hunger.enabled then
  local distance_interval = 15 --set distance check interval in seconds
  local hunger_per_meter = 1/250 --1 hp per 500 meter walk
  local hunger_per_cubic = 1/100 --1 hp per 100 blocks dig
  minetest.register_on_joinplayer(function(joiner)
    local player = joiner
    local name = player:get_player_name()
    minetest.after(5, function()
      hunger[name] = 0
      local pos_one = player:getpos()
      hunger.update(player, pos_one)
    end)
  end)
  hunger.update = function(player, pos_one)
    if player == nil or pos_one == nil then return end
    local pos_two = player:getpos()
    if pos_two == nil then return end
    local name = player:get_player_name()
    minetest.after(distance_interval, function()
      hunger.update(player,pos_two)
    end)
    hunger[name] = hunger[name] + vector.distance(pos_one,pos_two)*hunger_per_meter
    if hunger[name] >= 1 then
      local inv = player:get_inventory()
      if inv:contains_item("main", "default:apple") then
        inv:remove_item("main", "default:apple")
        hunger[name] = hunger[name] - 1
        minetest.sound_play({ name="survival_hunger_eat" }, {
          gain = 1.0;
          max_hear_distance = 16;
        });
      else
        player:set_hp(player:get_hp()-1)
        hunger[name] = hunger[name] - 1
        minetest.sound_play({ name="hunger_stomach" }, {
          gain = 1.0;
          max_hear_distance = 16;
        });
      end
    end
  end
  minetest.register_on_dignode(function(pos, oldnode, player)
    if hunger[name] ~= nil and player ~=nil then
      local name = player:get_player_name()
      hunger[name] = hunger[name] + hunger_per_cubic
      if hunger[name] >= 0.5 then
        player:set_hp(player:get_hp()-hunger[name])
        hunger[name] = hunger[name] - 1
      end
    end
  end)
end
