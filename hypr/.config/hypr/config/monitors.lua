-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Example: output can be found with hyprctl monitors. Edit variables.lua for the monitor outputs instead of here directly
-- hl.monitor({
--     output    = MONITOR1,
--     mode      = "1920x1080@60",
--     position  = "0x0",
--     scale     = "1",
-- })

-- hl.monitor({
--     output    = MONITOR1,
--     mode      = "preferred",
--     position  = "auto",
--     scale     = "auto",
-- })

hl.monitor({
	output = MONITOR1,
	mode = "1920x1200@165",
	position = "0x0",
	scale = 1.25,
})

-- hl.monitor({
-- 	output = MONITOR2,
-- 	mode = "1920x980@60",
-- 	position = "1536x0",
-- 	scale = 1,
-- })
