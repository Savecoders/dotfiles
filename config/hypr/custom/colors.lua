-- Static overrides load at startup. Wallpaper updates only refresh the generated
-- active-border gradient; config.reloaded callbacks and custom overrides are not
-- reapplied. Cached require("config.colors") references retain their identity.
return {}
