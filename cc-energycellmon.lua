-- https://github.com/ricksbrown/scripts/blob/master/cc-energycellmon.lua
-- Magmatic dynamos keep discharging (and therefore burn lava constantly).
-- This script measures any connected energy cells and, when they are all fully charged, outputs a redstone signal.
-- This can be used to turn off magmatic dynamos (or the fluiducts that feed them).
-- Energy cells can be added and removed and the script will adapt.
-- It is expected that energy cells (and a monitor) will be connected via network cables and modems.

-- Change REDSTONE_SIDE to reflect where you are connecting your redstone, e.g. "left"
-- Save this program in your computer, for example as "cellMonitor", you could use the command:
-- pastebin get u18MpTde cellMonitor
-- then call it from a program named "startup" like so:
-- shell.run("cellMonitor")

local REDSTONE_SIDE = "bottom"
local TOLERANCE = 0.1 -- Cell capacity can fall by this much before changing the output state
local POLL_INTERVAL = 6 -- How many seconds between checks, e.g. 6

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

local function logIt(msg)
	local monitor = findMonitor()
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
	local thresholdReached = false
	local i
	local periList = peripheral.getNames()
	local msg = "No energy cells found"
	logIt("")
	for i = 1, #periList do
		local nextType = peripheral.getType(periList[i])
		if nextType == ENERGY_CELL_TYPE then
			cellCount = cellCount + 1
			local currentLvl = peripheral.call(periList[i], "getEnergyStored", periList[i])
			local maxLvl = peripheral.call(periList[i], "getMaxEnergyStored", periList[i])
			local triggerLvl = maxLvl - (maxLvl * TOLERANCE)
			if currentLvl < maxLvl then
				allCharged = false
				if currentLvl < triggerLvl then
					thresholdReached = true
				end
			end
			msg = cleanName(periList[i])..": "..math.floor((currentLvl / maxLvl) * 100).."%"
			logIt(msg)
		end
	end
	if cellCount == 0 then
		logIt(msg)
	end
	if allCharged then
		-- There are no cells that need charging
		redstone.setOutput(REDSTONE_SIDE, true)
	elseif thresholdReached then
		-- A connected cell has gone below the allowed threshold
		redstone.setOutput(REDSTONE_SIDE, false)
	elseif redstone.getOutput(REDSTONE_SIDE) then
		-- Discharging but not reached threshold
		logIt("Will charge at < "..100 - (100 * TOLERANCE).."%")
	else
		-- Charging but not reached 100%
	end
	os.sleep(POLL_INTERVAL)
end
