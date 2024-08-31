-- Copied from https://github.com/rlch/github-notifications.nvim - Thanks!
-- All credit to https://github.com/f-person/lua-timeago

local M = {}

local function round(num)
  return math.floor(num + 0.5)
end

-- Returns a string formatted for the Last-Modified header
M.last_modified = function(seconds_since_epoch)
	if seconds_since_epoch == nil then
		seconds_since_epoch = os.time()
	end
	-- Here, ! enforces GMT
	return os.date('!%a, %d %b %Y %H:%M:%S GMT', seconds_since_epoch)
end

local zone_diff
-- Converts a GMT date table to local time
-- https://stackoverflow.com/questions/43067106/back-and-forth-utc-dates-in-lua
local gmt_to_local = function(dt)
	dt = os.date('*t', os.time(dt)) -- normalize regardless of TZ
	if not zone_diff then
		local tmp_time = os.time()
		local d1 = os.date('*t', tmp_time)
		local d2 = os.date('!*t', tmp_time)
		d1.isdst = false
		zone_diff = os.difftime(os.time(d1), os.time(d2))
	end

	dt.sec = dt.sec + zone_diff
	return os.time(dt)
end

-- Parse an ISO8601 string to a unix timestamp. Assumes UTC.
M.iso8601_to_unix = function(date)
	-- I hate dates
	local pattern = '(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%+%-])(%d?%d?)%:?(%d?%d?)'
	local year, month, day, hour, minute, seconds = date:match(pattern)

	local gmt_dt = os.date(
		'!*t',
		os.time { year = year, month = month, day = day, hour = hour, min = minute, sec = seconds }
	)
	return gmt_to_local(gmt_dt)
end

local language = {
	justnow = 'just now',
	minute = { singular = 'a minute ago', plural = 'minutes ago' },
	hour = { singular = 'an hour ago', plural = 'hours ago' },
	day = { singular = 'a day ago', plural = 'days ago' },
	week = { singular = 'a week ago', plural = 'weeks ago' },
	month = { singular = 'a month ago', plural = 'months ago' },
	year = { singular = 'a year ago', plural = 'years ago' },
}

function M.format(time)
	time = M.iso8601_to_unix(time)
	local now = os.time(os.date("!*t"))
	local diff_seconds = os.difftime(now, time)
	if diff_seconds < 45 then
		return language.justnow
	end

	local diff_minutes = diff_seconds / 60
	if diff_minutes < 1.5 then
		return language.minute.singular
	end
	if diff_minutes < 59.5 then
		return round(diff_minutes) .. ' ' .. language.minute.plural
	end

	local diff_hours = diff_minutes / 60
	if diff_hours < 1.5 then
		return language.hour.singular
	end
	if diff_hours < 23.5 then
		return round(diff_hours) .. ' ' .. language.hour.plural
	end

	local diff_days = diff_hours / 24
	if diff_days < 1.5 then
		return language.day.singular
	end
	if diff_days < 7.5 then
		return round(diff_days) .. ' ' .. language.day.plural
	end

	local diff_weeks = diff_days / 7
	if diff_weeks < 1.5 then
		return language.week.singular
	end
	if diff_weeks < 4.5 then
		return round(diff_weeks) .. ' ' .. language.week.plural
	end

	local diff_months = diff_days / 30
	if diff_months < 1.5 then
		return language.month.singular
	end
	if diff_months < 11.5 then
		return round(diff_months) .. ' ' .. language.month.plural
	end

	local diff_years = diff_days / 365.25
	if diff_years < 1.5 then
		return language.year.singular
	end
	return round(diff_years) .. ' ' .. language.year.plural
end

return M
