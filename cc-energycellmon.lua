-- https://github.com/ricksbrown/scripts/blob/master/cc-energycellmon.lua
-- Magmatic dynamos keep discharging (and therefore burn lava constantly).
-- This script measures any connected energy cells and, when they are all fully charged, outputs a rednet signal (use rednet cable).
-- This can be used to turn off magmatic dynamos (or the fluiducts that feed them).
-- Energy cells can be added and removed and the script will adapt.
-- It is expected that energy cells (and a monitor) will be connected via network cables and modems.

-- Change REDSTONE_SIDE to reflect where you are connecting your redstone, e.g. "left"
-- Change REDNET_CHANNEL if necessary
-- Save this program in your computer, for example as "cellMonitor", you could use the command:
-- pastebin get 8ZsGHWJa cellMonitor
-- then call it from a program named "startup" like so:
-- shell.run("cellMonitor")

local REDSTONE_SIDE = "right"
local REDNET_CHANNEL = colors.white
local REDNET_CHANNEL_OFF = colors.red
local REDNET_CHANNEL_ON = colors.lime
local DISCHARGE_TOLERANCE = 0.5 -- Cell capacity can fall by this much before changing the output state
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

-- returns -1 if forced off, 1 if forced on, otherwise 0
local function getOverrideState ()
	local inputState = redstone.getBundledInput(REDSTONE_SIDE)
	local forcedOff = colors.test(inputState, REDNET_CHANNEL_OFF)
	local forcedOn = colors.test(inputState, REDNET_CHANNEL_ON)
	if forcedOff then
		return -1
	elseif forcedOn then
		return 1
	else
		return 0
	end
end

while true do
	local cellCount = 0
	local allCharged = true
	local thresholdReached = false
	local override = getOverrideState()
	local i
	local periList = peripheral.getNames()
	local msg = "No energy cells found"
	logIt("")
	if override == 0 then
		for i = 1, #periList do
			local nextType = peripheral.getType(periList[i])
			if nextType == ENERGY_CELL_TYPE then
				cellCount = cellCount + 1
				local currentLvl = peripheral.call(periList[i], "getEnergyStored", periList[i])
				local maxLvl = peripheral.call(periList[i], "getMaxEnergyStored", periList[i])
				local triggerLvl = maxLvl - (maxLvl * DISCHARGE_TOLERANCE)
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
			redstone.setBundledOutput(REDSTONE_SIDE, REDNET_CHANNEL)
		elseif thresholdReached then
			-- A connected cell has gone below the allowed threshold
			redstone.setBundledOutput(REDSTONE_SIDE, 0)
		elseif redstone.testBundledInput(REDSTONE_SIDE, REDNET_CHANNEL) then
			-- Discharging but not reached threshold
			logIt("Will charge at < "..100 - (100 * DISCHARGE_TOLERANCE).."%")
		else
			-- Charging but not reached 100%
		end
	elseif override == -1 then
		redstone.setBundledOutput(REDSTONE_SIDE, REDNET_CHANNEL)
		logIt("Forced off")
	elseif override == 1 then
		redstone.setBundledOutput(REDSTONE_SIDE, 0)
		logIt("Forced on")
	end
	os.sleep(POLL_INTERVAL)
end
