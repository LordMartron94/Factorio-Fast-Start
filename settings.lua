--ENABLED OR NOT
data:extend({
  {
    type = "bool-setting",
    name = "hoorn-enable-fast-start",
    setting_type = "startup",
    default_value = true,
    order = "a"
  },
  {
    type = "bool-setting",
    name = "hoorn-enable-extended-fast-start",
    setting_type = "startup",
    default_value = false,
    order = "b"
  },
})
