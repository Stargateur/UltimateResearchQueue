require("__UltimateResearchQueue__.debug")

local dictionary = require("__flib__.dictionary")
local event = require("__flib__.event")
local libgui = require("__flib__.gui")
local migration = require("__flib__.migration")
local on_tick_n = require("__flib__.on-tick-n")

local constants = require("__UltimateResearchQueue__.constants")
local cache = require("__UltimateResearchQueue__.cache")
local gui = require("__UltimateResearchQueue__.gui.index")
local migrations = require("__UltimateResearchQueue__.migrations")
local queue = require("__UltimateResearchQueue__.queue")
local util = require("__UltimateResearchQueue__.util")

local function build_dictionaries()
  dictionary.init()
  -- Each technology should be searchable by its name and the names of recipes it unlocks
  local recipes = dictionary.new("recipe")
  for name, recipe in pairs(game.recipe_prototypes) do
    recipes:add(name, recipe.localised_name)
  end
  local techs = dictionary.new("technology")
  for name, technology in pairs(game.technology_prototypes) do
    techs:add(name, technology.localised_name)
  end
end

event.on_init(function()
  build_dictionaries()
  cache.build_effect_icons()
  cache.build_technology_list()
  on_tick_n.init()

  --- @type table<uint, ForceTable>
  global.forces = {}
  --- @type table<uint, PlayerTable>
  global.players = {}

  -- game.forces is apparently keyed by name, not index
  for _, force in pairs(game.forces) do
    migrations.init_force(force)
    migrations.migrate_force(force)
  end
  for _, player in pairs(game.players) do
    migrations.init_player(player.index)
    migrations.migrate_player(player)
  end
end)

event.on_load(function()
  dictionary.load()
  for _, force_table in pairs(global.forces) do
    queue.load(force_table.queue)
  end
  for _, player_table in pairs(global.players) do
    if player_table.gui then
      gui.load(player_table.gui)
    end
  end
end)

event.on_configuration_changed(function(e)
  if migration.on_config_changed(migrations.by_version, e) then
    build_dictionaries()
    cache.build_effect_icons()
    cache.build_technology_list()
    for _, force in pairs(game.forces) do
      migrations.migrate_force(force)
    end
    for _, player in pairs(game.players) do
      migrations.migrate_player(player)
    end
  end
end)

event.on_force_created(function(e)
  migrations.init_force(e.force)
  migrations.migrate_force(e.force)
end)

event.on_player_created(function(e)
  migrations.init_player(e.player_index)
  migrations.migrate_player(game.get_player(e.player_index) --[[@as LuaPlayer]])
end)

event.on_player_joined_game(function(e)
  dictionary.translate(game.get_player(e.player_index) --[[@as LuaPlayer]])
end)

event.on_player_left_game(function(e)
  dictionary.cancel_translation(e.player_index)
end)

event.register({
  defines.events.on_player_toggled_map_editor,
  defines.events.on_player_cheat_mode_enabled,
  defines.events.on_player_cheat_mode_disabled,
}, function(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  local gui = util.get_gui(player)
  if gui then
    gui:update_tech_info_footer()
  end
end)

libgui.hook_events(function(e)
  local action = libgui.read_action(e)
  if action then
    local gui = util.get_gui(e.player_index)
    if gui then
      gui:dispatch(action, e)
    end
  end
end)

if not DEBUG then
  event.on_gui_opened(function(e)
    local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
    if player.opened_gui_type == defines.gui_type.research then
      local gui = util.get_gui(player)
      if gui and not gui.state.opening_graph then
        local opened = player.opened --[[@as LuaTechnology?]]
        player.opened = nil
        gui:show(opened and opened.name or nil)
      end
    end
  end)
end

event.on_gui_closed(function(e)
  local action = libgui.read_action(e)
  if action then
    local gui = util.get_gui(e.player_index)
    if gui then
      gui:dispatch(action, e)
    end
  elseif e.gui_type == defines.gui_type.research then
    local gui = util.get_gui(e.player_index)
    if gui and gui.refs.window.visible and not gui.state.pinned then
      gui.player.opened = gui.refs.window
    end
  end
end)

event.register("urq-focus-search", function(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  if player.opened_gui_type == defines.gui_type.custom and player.opened and player.opened.name == "urq-window" then
    local gui = util.get_gui(player)
    if gui then
      gui:toggle_search()
    end
  end
end)

event.register("urq-toggle-gui", function(e)
  local gui = util.get_gui(e.player_index)
  if gui then
    gui:toggle_visible()
  end
end)

event.on_lua_shortcut(function(e)
  if e.prototype_name == "urq-toggle-gui" then
    local gui = util.get_gui(e.player_index)
    if gui then
      gui:toggle_visible()
    end
  end
end)

event.on_research_started(function(e)
  local technology = e.research
  local force = technology.force
  local force_table = global.forces[force.index]
  if not force_table then
    return
  end
  util.ensure_queue_disabled(force)

  local queue = force_table.queue
  if next(queue.queue) ~= technology.name then
    queue:push_front({ technology.name })
  end
end)

event.on_research_cancelled(function(e)
  local force = e.force
  local force_table = global.forces[force.index]
  if not force_table then
    return
  end
  util.ensure_queue_disabled(force)

  local queue = force_table.queue
  if queue.paused then
    return
  end
  for tech_name in pairs(e.research) do
    queue:remove(tech_name)
  end
end)

event.on_research_finished(function(e)
  local technology = e.research
  local force = technology.force
  local force_table = global.forces[force.index]
  if not force_table then
    return
  end
  util.ensure_queue_disabled(force)
  if force_table.queue:contains(technology.name) then
    force_table.queue:remove(technology.name)
  else
    -- This was insta-researched
    util.update_research_state_reqs(force_table, technology)
    util.schedule_gui_update(force_table)
  end
  for _, player in pairs(force.players) do
    if player.mod_settings["urq-print-completed-message"].value then
      player.print({ "message.urq-research-completed", technology.name })
    end
  end
end)

event.on_research_reversed(function(e)
  local technology = e.research
  local force = technology.force
  local force_table = global.forces[force.index]
  if not force_table then
    return
  end
  util.ensure_queue_disabled(force)
  util.update_research_state_reqs(force_table, e.research)
  util.schedule_gui_update(force_table)
end)

event.register(constants.on_research_queue_updated, function(e)
  util.schedule_gui_update(global.forces[e.force.index])
end)

event.on_string_translated(function(e)
  local result = dictionary.process_translation(e)
  if result then
    for _, player_index in pairs(result.players) do
      local player_table = global.players[player_index]
      if player_table then
        player_table.dictionaries = result.dictionaries
      end
    end
  end
end)

event.on_tick(function(e)
  dictionary.check_skipped()
  for _, job in pairs(on_tick_n.retrieve(e.tick) or {}) do
    if job.id == "update_guis" then
      -- TODO: Update each player's GUI on a separate tick?
      local force_table = global.forces[job.force]
      force_table.update_gui_task = nil
      util.update_force_guis(force_table.force)
    elseif job.id == "gui" then
      local gui = util.get_gui(job.player_index)
      if gui then
        gui:dispatch(job, e)
      end
    end
  end
end)

event.on_nth_tick(60, function()
  for force_index, force_table in pairs(global.forces) do
    local force = game.forces[force_index]
    local current = force.current_research
    if current then
      local samples = force_table.research_progress_samples
      --- @class ProgressSample
      local sample = { progress = force.research_progress, tech = current.name }
      table.insert(samples, sample)
      if #samples > 3 then
        table.remove(samples, 1)
      end

      local speed = 0
      local num_samples = 0
      if #samples > 1 then
        for i = 2, #samples do
          local previous_sample = samples[i - 1]
          local current_sample = samples[i]
          if previous_sample.tech == current_sample.tech then
            -- How much the progress increased per tick
            local diff = (current_sample.progress - previous_sample.progress) / 60
            -- Don't add if the speed is negative for whatever reason
            if diff > 0 then
              speed = speed + diff * util.get_research_unit_count(current) * current.research_unit_energy
              num_samples = num_samples + 1
            end
          end
        end
        -- Rolling average
        if num_samples > 0 then
          speed = speed / num_samples
        end
      end

      force_table.queue:update_durations(speed)

      for _, player in pairs(force.players) do
        local gui = util.get_gui(player)
        if gui then
          gui:update_durations_and_progress()
        end
      end
    end
  end
end)
