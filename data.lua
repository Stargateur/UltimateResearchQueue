require("__UltimateResearchQueue__.debug")

data:extend({
  {
    type = "custom-input",
    name = "urq-focus-search",
    key_sequence = "",
    linked_game_control = "focus-search",
  },
  -- TODO: Make this optional
  {
    type = "custom-input",
    name = "urq-toggle-gui",
    key_sequence = "",
    linked_game_control = "open-technology-gui",
    consuming = "game-only",
  },
  {
    type = "font",
    name = "urq-technology-slot-duration",
    from = "default-bold",
    border = true,
    border_color = {},
    size = 13,
  },
})

local styles = data.raw["gui-style"].default

--- @param name string
--- @param y number
--- @param level_color Color
--- @param level_range_color Color
local function technology_slot(name, y, level_color, level_range_color)
  styles["urq_technology_slot_" .. name] = {
    type = "button_style",
    default_graphical_set = {
      base = {
        filename = "__UltimateResearchQueue__/graphics/technology-slots.png",
        position = { 0, y },
        size = { 144, 200 },
      },
      shadow = default_shadow,
    },
    hovered_graphical_set = {
      base = {
        filename = "__UltimateResearchQueue__/graphics/technology-slots.png",
        position = { 144, y },
        size = { 144, 200 },
      },
      shadow = default_shadow,
    },
    clicked_graphical_set = {
      base = {
        filename = "__UltimateResearchQueue__/graphics/technology-slots.png",
        position = { 144, y },
        size = { 144, 200 },
      },
      shadow = default_shadow,
    },
    padding = 0,
    size = { 72, 100 },
    left_click_sound = { filename = "__core__/sound/gui-square-button-large.ogg", volume = 1 },
  }

  styles["urq_technology_slot_selected_" .. name] = {
    type = "button_style",
    default_graphical_set = {
      base = {
        filename = "__UltimateResearchQueue__/graphics/technology-slots.png",
        position = { 288, y },
        size = { 144, 200 },
      },
      shadow = default_shadow,
    },
    hovered_graphical_set = {
      base = {
        filename = "__UltimateResearchQueue__/graphics/technology-slots.png",
        position = { 432, y },
        size = { 144, 200 },
      },
      shadow = default_shadow,
    },
    clicked_graphical_set = {
      base = {
        filename = "__UltimateResearchQueue__/graphics/technology-slots.png",
        position = { 432, y },
        size = { 144, 200 },
      },
      shadow = default_shadow,
    },
    padding = 0,
    size = { 72, 100 },
    left_click_sound = { filename = "__core__/sound/gui-square-button-large.ogg", volume = 1 },
  }

  styles["urq_technology_slot_leveled_" .. name] = {
    type = "button_style",
    default_graphical_set = {
      base = {
        filename = "__UltimateResearchQueue__/graphics/technology-slots.png",
        position = { 576, y },
        size = { 144, 200 },
      },
      shadow = default_shadow,
    },
    hovered_graphical_set = {
      base = {
        filename = "__UltimateResearchQueue__/graphics/technology-slots.png",
        position = { 720, y },
        size = { 144, 200 },
      },
      shadow = default_shadow,
    },
    clicked_graphical_set = {
      base = {
        filename = "__UltimateResearchQueue__/graphics/technology-slots.png",
        position = { 720, y },
        size = { 144, 200 },
      },
      shadow = default_shadow,
    },
    padding = 0,
    size = { 72, 100 },
    left_click_sound = { filename = "__core__/sound/gui-square-button-large.ogg", volume = 1 },
  }

  styles["urq_technology_slot_selected_leveled_" .. name] = {
    type = "button_style",
    default_graphical_set = {
      base = {
        filename = "__UltimateResearchQueue__/graphics/technology-slots.png",
        position = { 864, y },
        size = { 144, 200 },
      },
      shadow = default_shadow,
    },
    hovered_graphical_set = {
      base = {
        filename = "__UltimateResearchQueue__/graphics/technology-slots.png",
        position = { 1008, y },
        size = { 144, 200 },
      },
      shadow = default_shadow,
    },
    clicked_graphical_set = {
      base = {
        filename = "__UltimateResearchQueue__/graphics/technology-slots.png",
        position = { 1008, y },
        size = { 144, 200 },
      },
      shadow = default_shadow,
    },
    padding = 0,
    size = { 72, 100 },
    left_click_sound = { filename = "__core__/sound/gui-square-button-large.ogg", volume = 1 },
  }

  styles["urq_technology_slot_level_label_" .. name] = {
    type = "label_style",
    font = "technology-slot-level-font",
    font_color = level_color,
    top_padding = 66,
    width = 26,
    horizontal_align = "center",
  }

  styles["urq_technology_slot_level_range_label_" .. name] = {
    type = "label_style",
    font = "technology-slot-level-font",
    font_color = level_range_color,
    top_padding = 66,
    right_padding = 4,
    width = 72,
    horizontal_align = "right",
  }
end

technology_slot("available", 0, { 77, 71, 48 }, { 255, 241, 183 })
technology_slot("conditionally_available", 200, { 95, 68, 32 }, { 255, 234, 206 })
technology_slot("not_available", 400, { 116, 34, 32 }, { 255, 214, 213 })
technology_slot("researched", 600, { 0, 84, 5 }, { 165, 255, 171 })
technology_slot("disabled", 800, { 132, 132, 132 }, { 132, 132, 132 })

styles.urq_technology_slot_sprite_flow = {
  type = "horizontal_flow_style",
  width = 72,
  height = 68,
  vertical_align = "center",
  horizontal_align = "center",
}

styles.urq_technology_slot_sprite = {
  type = "image_style",
  size = 64,
  stretch_image_to_widget_size = true,
}

styles.urq_technology_slot_duration_label = {
  type = "label_style",
  font = "urq-technology-slot-duration",
  height = 70,
  left_padding = 4,
  vertical_align = "bottom",
}

styles.urq_technology_slot_ingredients_flow = {
  type = "horizontal_flow_style",
  top_padding = 82,
  left_padding = 2,
}

styles.urq_technology_slot_ingredient = {
  type = "image_style",
  size = 16,
  stretch_image_to_widget_size = true,
}

styles.urq_technology_slot_progressbar = {
  type = "progressbar_style",
  bar = { position = { 305, 39 }, corner_size = 4 },
  bar_shadow = {
    base = { position = { 296, 39 }, corner_size = 4 },
    shadow = {
      left = { position = { 456, 152 }, size = { 16, 1 } },
      center = { position = { 472, 152 }, size = { 1, 1 } },
      right = { position = { 473, 152 }, size = { 16, 1 } },
    },
  },
  bar_width = 4,
  color = { g = 1 },
  width = 72,
}

styles.urq_tech_list_scroll_pane = {
  type = "scroll_pane_style",
  parent = "flib_naked_scroll_pane_no_padding",
  background_graphical_set = styles.technology_list_scroll_pane.background_graphical_set,
}

styles.urq_search_textfield = {
  type = "textbox_style",
  top_margin = -3,
  right_padding = 3,
}

styles.urq_invalid_search_textfield = {
  type = "textbox_style",
  parent = "invalid_value_textfield",
  top_margin = -3,
  right_padding = 3,
}

if DEBUG then
  data.raw["technology"]["automation"].effects = {
    {
      type = "ammo-damage",
      ammo_category = "bullet",
      modifier = 100,
    },
    {
      type = "artillery-range",
      modifier = 100,
    },
    {
      type = "character-build-distance",
      modifier = 100,
    },
    {
      type = "character-build-distance",
      modifier = 100,
    },
    {
      type = "character-crafting-speed",
      modifier = 100,
    },
    {
      type = "character-health-bonus",
      modifier = 100,
    },
    {
      type = "character-inventory-slots-bonus",
      modifier = 100,
    },
    {
      type = "character-item-drop-distance",
      modifier = 100,
    },
    {
      type = "character-item-pickup-distance",
      modifier = 100,
    },
    {
      type = "character-logistic-requests",
      modifier = 100,
    },
    {
      type = "character-logistic-trash-slots",
      modifier = 100,
    },
    {
      type = "character-loot-pickup-distance",
      modifier = 100,
    },
    {
      type = "character-mining-speed",
      modifier = 100,
    },
    {
      type = "character-reach-distance",
      modifier = 100,
    },
    {
      type = "character-resource-reach-distance",
      modifier = 100,
    },
    {
      type = "character-running-speed",
      modifier = 100,
    },
    {
      type = "deconstruction-time-to-live",
      modifier = 100,
    },
    {
      type = "follower-robot-lifetime",
      modifier = 100,
    },
    {
      type = "ghost-time-to-live",
      modifier = 100,
    },
    {
      type = "give-item",
      item = "iron-plate",
      count = 2,
    },
    {
      type = "gun-speed",
      ammo_category = "bullet",
      modifier = 100,
    },
    {
      type = "inserter-stack-size-bonus",
      modifier = 100,
    },
    {
      type = "laboratory-productivity",
      modifier = 100,
    },
    {
      type = "laboratory-speed",
      modifier = 100,
    },
    {
      type = "max-failed-attempts-per-tick-per-construction-queue",
      modifier = 100,
    },
    {
      type = "max-successful-attempts-per-tick-per-construction-queue",
      modifier = 100,
    },
    {
      type = "maximum-following-robots-count",
      modifier = 100,
    },
    {
      type = "mining-drill-productivity-bonus",
      modifier = 100,
    },
    {
      type = "nothing",
      effect_description = "My custom description",
    },
    {
      type = "stack-inserter-capacity-bonus",
      modifier = 100,
    },
    {
      type = "train-braking-force-bonus",
      modifier = 100,
    },
    {
      type = "turret-attack",
      turret_id = "gun-turret",
      modifier = 100,
    },
    {
      type = "unlock-recipe",
      recipe = "assembling-machine-1",
    },
    {
      type = "unlock-recipe",
      recipe = "long-handed-inserter",
    },
    {
      type = "worker-robot-battery",
      modifier = 100,
    },
    {
      type = "worker-robot-speed",
      modifier = 100,
    },
    {
      type = "worker-robot-storage",
      modifier = 100,
    },
    {
      type = "zoom-to-world-blueprint-enabled",
      modifier = true,
    },
    {
      type = "zoom-to-world-deconstruction-planner-enabled",
      modifier = true,
    },
    {
      type = "zoom-to-world-enabled",
      modifier = true,
    },
    {
      type = "zoom-to-world-ghost-building-enabled",
      modifier = true,
    },
    {
      type = "zoom-to-world-selection-tool-enabled",
      modifier = true,
    },
    {
      type = "zoom-to-world-upgrade-planner-enabled",
      modifier = true,
    },
  }
end
