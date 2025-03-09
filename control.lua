local enable_tech_list = {
  "fuel-processing",
  "electricity",
  "electric-mining",
  "basic-fluid-handling",
  "automation",
  "bio-processing-brown",
  "basic-chemistry",
  "bio-paper-1",
  "angels-solder-smelting-basic",
  "tech-red-circuit",
  "angels-components-mechanical-1",
  "angels-basic-blocks-1",
  "ore-crushing",
  "bob-logistics",
  "basic-logistics-2",
  "logistics-0",
  "logistics",
  "long-inserters-1"
}

local function research_tech()
  for _, force in pairs(game.forces) do
    for _, tech_name in pairs(enable_tech_list) do
      if force.technologies[tech_name] then
        force.technologies[tech_name].researched = true
      end
    end
  end
end

local function place_item_nearby_player(item_name)
  local surface = game.surfaces["nauvis"]

  local center_search = {x = 0, y = 0 - 32}
  local radius = 8
  local precision = 0.01
  local force_to_tile_center = true

  local place_position = surface.find_non_colliding_position(item_name, center_search, radius, precision, force_to_tile_center)
  return surface.create_entity({name=item_name, position=place_position, force="player"})
end

local function spawn_new_chest()
  return place_item_nearby_player("iron-chest")
end

local function give_items_to_player_through_chests(items)
  local chest = spawn_new_chest()
  for _, item in pairs(items) do
    local item_name, count = item[1], item[2]
    local item_prototype = game.item_prototypes[item_name]
    if item_prototype then
      local stack_size = item_prototype.stack_size
      while (count > 0) do
        if (chest.get_inventory(defines.inventory.chest).is_full()) then
          chest = spawn_new_chest()
        end
        if (count > stack_size) then
          chest.insert({name=item_name, count=stack_size})
          count = count - stack_size
        else
          chest.insert({name=item_name, count=count})
          count = 0
        end
      end
    else
      global.hoorn_debug_string = global.hoorn_debug_string or {}
      table.insert(global.hoorn_debug_string, "Item Prototype for " .. item_name .. " does not exist.")
    end
  end
end

local function give_items_to_player_through_chests_collection(items_collection)
  for items in items_collection do
    give_items_to_player_through_chests(items)
  end
end

script.on_event(defines.events.on_player_created, function (event)
  if global.hoorn_debug_string then
    for _, message in ipairs(global.hoorn_debug_string) do
      game.print(message)
    end
    global.hoorn_debug_string = nil
  end
end)

script.on_init(function (event)
  if (not settings.startup["hoorn-enable-fast-start"]) then
     return
  end
  logistic_items = {
    {"transport-belt", 8000},
    {"splitter", 150},
    {"underground-belt", 700},
    {"iron-chest", 120},
    {"Construction Drone", 10}
  }

  production_items = {
    {"electric-mining-drill", 400},
    {"stone-furnace", 250},
    {"inserter", 1000},
    {"assembling-machine-1", 200},
    {"ore-crusher", 50}
  }

  power_items = {
      {"offshore-pump", 1},
      {"boiler", 20},
      {"steam-engine", 40},
      {"pipe", 9},
      {"pipe-to-ground", 2},
      {"small-electric-pole", 200},
      {"burner-turbine", 1}
  }

  other_items = {
    {"car", 1}
  }

  give_items_to_player_through_chests_collection({logistic_items, production_items, power_items, other_items})

  if (settings.startup["hoorn-enable-extended-fast-start"]) then
    extended_logistics = {
      {"transport-belt", 16000},
      {"splitter", 700},
      {"underground-belt", 1400},
      {"iron-chest", 240}
    }

    extended_production = {
      {"electric-mining-drill", 200},
      {"inserter", 2000},
      {"assembling-machine-1", 500},
      {"ore-crusher", 200}
    }

    extended_power = {
      {"small-electric-pole", 500}
    }

    give_items_to_player_through_chests_collection({extended_logistics, extended_production, extended_power})
  end

  research_tech()
end)
