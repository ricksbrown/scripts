-- Magmatic dynamos keep discharging (and therefore burn lava constantly).
-- This script measures any connected energy cells and, when they are all fully charged, outputs a redstone signal.
-- This can be used to turn off magmatic dynamos (or the fluiducts that feed them).
-- Energy cells can be added and removed and the script will adapt.
-- It is expected that energy cells (and a monitor) will be connected via network cables and modems.

-- Change REDSTONE_SIDE to reflect where you are connecting your redstone, e.g. "left"
-- Save this program in your computer, for example as "cellMonitor", you could use the command:
-- pastebin get eTHATa9W cellMonitor
-- then call it from a program named "startup" like so:
-- shell.run("cellMonitor")

local REDSTONE_SIDE = "left"

local function findMonitor()
	local i
	local periList = peripheral.getNames()
	for i = 1, #periList do
		if peripheral.getType(periList[i]) == "monitor" then
			return peripheral.wrap(periList[i])
		end
	end
end

local ENERGY_CELL_TYPE = "cofh_thermalexpansion_energycell"
local linePtr = 1
local monitor = findMonitor()

local function logIt(msg)
	if msg == nil or msg == "" then
		if monitor ~= nil then
			monitor.clear()
			linePtr = 1
		end
	else
		print(msg)
		if monitor ~= nil then
			monitor.setCursorPos(1, linePtr)
			monitor.write(msg)
			linePtr = linePtr + 1
		end
	end
end

local function cleanName(name)
	return string.gsub(name, ENERGY_CELL_TYPE, "Energy Cell")
end

while true do
	local cellCount = 0
	local allCharged = true
	local i
	local periList = peripheral.getNames()
	local msg = "No energy cells"
	logIt("")
	for i = 1, #periList do
		local nextType = peripheral.getType(periList[i])
		if nextType == ENERGY_CELL_TYPE then
			cellCount = cellCount + 1
			local currentLvl = peripheral.call(periList[i], "getEnergyStored", periList[i])
			local maxLvl = peripheral.call(periList[i], "getMaxEnergyStored", periList[i])
			if currentLvl < maxLvl then
				allCharged = false
			end
			msg = cleanName(periList[i])..": "..math.floor((currentLvl / maxLvl) * 100).."%"
			logIt(msg)
		end
	end
	if cellCount == 0 then
		logIt(msg)
	end
	redstone.setOutput(REDSTONE_SIDE, allCharged)
	os.sleep(6)
end
