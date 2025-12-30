---@class DREAMBase
local DREAMBase = {}

DREAMBase.log = require("DREAMBase/log")
DREAMBase.util = require("DREAMBase/util")
DREAMBase.time_ms = require("DREAMBase/time_ms")
DREAMBase.events = require("DREAMBase/events")

DREAMBase.pz = {
	java_list = require("DREAMBase/pz/java_list"),
	safe_call = require("DREAMBase/pz/safe_call"),
}

return DREAMBase

