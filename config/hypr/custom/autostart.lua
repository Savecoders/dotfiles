-- You can make apps auto-start here

hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@60",
	position = "0x0",
	icc = os.getenv("HOME") .. "/Downloads/DISPLAY1_fa0666TX_optimized.icm",
	scale = 1,
})

hl.monitor({
	output = "HDMI-A-1",
	mode = "1920x1080@60",
	position = "1920x0",
	scale = 1,
})
