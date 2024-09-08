-- Copied from https://github.com/rlch/github-notifications.nvim - Thanks!
-- All credit to https://github.com/f-person/lua-timeago

local function round(num)
	return math.floor(num + 0.5)
end

local gmt_to_local = function(dt)
	dt = os.date('*t', os.time(dt))
	local tmp_time = os.time()
	local d1 = os.date('*t', tmp_time)
	local d2 = os.date('!*t', tmp_time)
	d1.isdst = false
	local zone_diff = os.difftime(os.time(d1), os.time(d2))
	dt.sec = dt.sec + zone_diff
	return os.time(dt)
end

local iso8601_to_unix = function(date)
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

local M = {}

function M.format(time)
	time = iso8601_to_unix(time)
	local now = os.time(os.date("!*t"))
	local diff_seconds = os.difftime(now, time)
	if diff_seconds < 45 then
		return language.justnow
	end

	local diff_minutes = diff_seconds / 60
	if diff_minutes < 1.5 then
		return language.minute.singular
	elseif diff_minutes < 59.5 then
		return round(diff_minutes) .. ' ' .. language.minute.plural
	end

	local diff_hours = diff_minutes / 60
	if diff_hours < 1.5 then
		return language.hour.singular
	elseif diff_hours < 23.5 then
		return round(diff_hours) .. ' ' .. language.hour.plural
	end

	local diff_days = diff_hours / 24
	if diff_days < 1.5 then
		return language.day.singular
	elseif diff_days < 7.5 then
		return round(diff_days) .. ' ' .. language.day.plural
	end

	local diff_weeks = diff_days / 7
	if diff_weeks < 1.5 then
		return language.week.singular
	elseif diff_weeks < 4.5 then
		return round(diff_weeks) .. ' ' .. language.week.plural
	end

	local diff_months = diff_days / 30
	if diff_months < 1.5 then
		return language.month.singular
	elseif diff_months < 11.5 then
		return round(diff_months) .. ' ' .. language.month.plural
	end

	local diff_years = diff_days / 365.25
	if diff_years < 1.5 then
		return language.year.singular
	end
	return round(diff_years) .. ' ' .. language.year.plural
end

return M
