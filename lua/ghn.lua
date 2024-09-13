local utils = require("utils/utils")
local time = require("utils/time")
local augroup = vim.api.nvim_create_augroup("GHN", { clear = true })
local token = ""
local _flags = {
	i = false,
	pr = false,
	n = false
}


local M = {}

M._notifications = {}
M._pull_requests = {}
M._issues = {}

local default_opts = {
	default_open = false,
	toggle_marks = {
		open = "v",
		closed = ">"
	},
	mappings = {
		toggle_item = "o",
		close_all = "u",
		open_item = "O",
		refresh = "R",
		copy_url = "Y",
		copy_number = "<C-y>",
		mark_as_read = "<C-r>",
		open_in_browser = "<C-o>",
	}
}
local opts = default_opts

M.start = function()
	local path = debug.getinfo(1).source:gsub("@", ""):gsub("/ghn%.lua", "")
	local f = io.open(path .. "/ghn.pass", "r")
	if not f then
		token = utils.prompt_for_token(path)
	else
		token = f:read("*all")
		f:close()
	end
	M.open()
end

M.display = function()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local lines = {
		"Github Dashboard",
		"",
		"Notifications (" .. #M._notifications .. ")",
	}
	local opened_items = 0
	for i, notification in ipairs(M._notifications) do
		notification.line = 3 + i + (opened_items * 4)
		local line = ""
		if notification.open then
			line = opts.toggle_marks.open
		else
			line = opts.toggle_marks.closed
		end
		line = line ..
			" " ..
			notification.type ..
			" #" .. notification.number .. " - " .. notification.title .. " [N.id " .. notification.id .. "]"
		table.insert(lines, line)
		if notification.open then
			opened_items = opened_items + 1
			table.insert(lines, "\t| Repo: " .. notification.repository)
			table.insert(lines, "\t| Reason: " .. notification.reason)
			table.insert(lines, "\t| Url: " .. notification.url)
			table.insert(lines, "\t| Updated: " .. time.format(notification.updated_at))
		end
	end
	table.insert(lines, "")
	table.insert(lines, "Assigned issues (" .. #M._issues .. ")")
	opened_items = 0
	for i, issue in ipairs(M._issues) do
		issue.line = 3 + #M._notifications + 2 + i + (opened_items * 3)
		local line = ""
		if issue.open then
			line = opts.toggle_marks.open
		else
			line = opts.toggle_marks.closed
		end
		line = line .. " #" .. issue.number .. " - " .. issue.title .. " [I.id " .. issue.id .. "]"
		table.insert(lines, line)
		if issue.open then
			opened_items = opened_items + 1
			table.insert(lines, "\t| Author: @" .. issue.author)
			local tags = ""
			for j, tag in ipairs(issue.labels) do
				tags = tags .. tag.name
				if j < #tags then
					tags = tags .. ", "
				end
			end
			table.insert(lines, "\t| Tags: " .. tags)
			table.insert(lines, "\t| Url: " .. issue.url)
			table.insert(lines, "\t| Updated: " .. time.format(issue.updated_at))
		end
	end
	table.insert(lines, "")
	table.insert(lines, "Opened PRs (" .. #M._pull_requests .. ")")
	opened_items = 0
	for i, pr in ipairs(M._pull_requests) do
		pr.line = 3 + #M._notifications + 2 + #M._issues + 2 + i + (opened_items * 3)
		local line = ""
		if pr.open then
			line = opts.toggle_marks.open
		else
			line = opts.toggle_marks.closed
		end
		line = line .. " #" .. pr.number .. " - " .. pr.title .. " [PR.id " .. pr.id .. "]"
		table.insert(lines, line)
		if pr.open then
			opened_items = opened_items + 1
			table.insert(lines, "\t| Repo: " .. pr.repository)
			table.insert(lines, "\t| Url: " .. pr.url)
			table.insert(lines, "\t| Updated: " .. time.format(pr.updated_at))
		end
	end
	vim.api.nvim_set_option_value("modified", true, { scope = "local" })
	vim.api.nvim_set_option_value("modifiable", true, { scope = "local" })
	vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
	vim.api.nvim_buf_set_lines(0, 0, #lines, false, lines)
	vim.api.nvim_set_option_value("modified", false, { scope = "local" })
	vim.api.nvim_set_option_value("modifiable", false, { scope = "local" })
	vim.api.nvim_win_set_buf(0, 0)
	local line_count = vim.api.nvim_buf_line_count(0)
	if line_count < cursor[1] then
		cursor[1] = line_count
	end
	vim.api.nvim_win_set_cursor(0, cursor)
end

M.close_all = function()
	for _, i in ipairs(M._issues) do
		i.open = false
	end
	for _, n in ipairs(M._notifications) do
		n.open = false
	end
	for _, p in ipairs(M._pull_requests) do
		p.open = false
	end
	M.display()
end

M.toggle_item = function()
	local cursor = vim.api.nvim_win_get_cursor(0)[1]
	local id = utils.get_item_id(cursor)
	local type = utils.get_item_type(cursor)
	if not id then
		return vim.notify("Cursor not in a valid item", vim.log.levels.ERROR)
	else
		local type_list = {}
		if type == 'issue' then
			type_list = M._issues
		elseif type == 'notification' then
			type_list = M._notifications
		elseif type == 'pr' then
			type_list = M._pull_requests
		end
		local r = utils.find_by_id(type_list, id)
		r.n.open = not r.n.open
		type_list[r.i] = r.n
		M.display()
		vim.api.nvim_win_set_cursor(0, { r.n.line, 0 })
	end
end

M.toggle_multiple_items = function()
	local cursor = vim.api.nvim_win_get_cursor(0)[1]
	local ids = utils.get_multiple_item_ids()
	if not ids then
		return vim.notify("Cursor not in a valid item", vim.log.levels.ERROR)
	end
	for _, item in ipairs(ids) do
		local list = {}
		if item.type == "issue" then
			list = M._issues
		elseif item.type == "notification" then
			list = M._notifications
		elseif item.type == "pr" then
			list = M._pull_requests
		end
		local r = utils.find_by_id(list, item.id)
		r.n.open = not r.n.open
		list[r.i] = r.n
	end
	M.display()
	local lastLine = vim.api.nvim_buf_line_count(0)
	if lastLine < cursor then
		cursor = lastLine
	end
	vim.api.nvim_win_set_cursor(0, { cursor, 0 })
end

M.get_notifications = function()
	vim.notify("Fetching notifications", vim.log.levels.INFO)
	local url = "https://api.github.com/notifications"
	vim.system(
		{ 'curl', '-s', '-X', 'GET', '-H', 'Authorization: Bearer ' .. token, '-H', 'Accept: application/vnd.github+json',
			url }, {}, vim.schedule_wrap(function(result)
			vim.system(
				{ 'jq', '-cj',
					'[ .[] | {"id": .id, "title": .subject.title, "url": .subject.url, "reason": .reason, "type": .subject.type, "repository": .repository.full_name, "updated_at": .updated_at } ]' },
				{ stdin = result.stdout:gsub("\n", " ") }, vim.schedule_wrap(function(parsed)
					M._notifications = {}
					for _, item in ipairs(vim.json.decode(parsed.stdout)) do
						item.open = opts.default_open
						item.number = item.url:match("%d*$")
						item.url = item.url:gsub("api%.", ""):gsub("repos/", "")
						if item.type == "PullRequest" then
							item.url = item.url:gsub("s/" .. item.number .. "$", "/" .. item.number)
						end
						table.insert(M._notifications, item)
					end
					if _flags.pr and _flags.i then
						M.display()
						_flags.pr = false
						_flags.i = false
					else
						_flags.n = true
					end
				end))
		end))
end

M.get_pull_requests = function()
	vim.notify("Fetching pull requests", vim.log.levels.INFO)
	local url = "https://api.github.com/search/issues?q=+type:pr+author:@me+state:open"
	vim.system(
		{ 'curl', '-s', '-X', 'GET', '-H', 'Authorization: Bearer ' .. token, '-H',
			'Accept: application/vnd.github.text-match+json', url }, {}, vim.schedule_wrap(function(result)
			vim.system(
				{ 'jq', '-cj',
					'[ .items.[] | {"id": .id, "title": .title, "url": .html_url, "author": .user.login, "repository": .repository_url, "updated_at": .updated_at } ]' },
				{ stdin = result.stdout:gsub("\n", " ") }, vim.schedule_wrap(function(parsed)
					M._pull_requests = {}
					for _, item in ipairs(vim.json.decode(parsed.stdout)) do
						item.id = tostring(item.id)
						item.open = opts.default_open
						item.number = item.url:match("%d*$")
						item.repository = item.repository:gsub("https://api%.github%.com/repos/", "")
						table.insert(M._pull_requests, item)
					end
					if _flags.n and _flags.i then
						M.display()
						_flags.n = false
						_flags.i = false
					else
						_flags.pr = true
					end
				end))
		end))
end

M.get_issues = function()
	vim.notify("Fetching issues", vim.log.levels.INFO)
	local url = "https://api.github.com/issues"
	vim.system(
		{ 'curl', '-s', '-X', 'GET', '-H', 'Authorization: Bearer ' .. token, '-H', 'Accept: application/vnd.github+json',
			url }, {}, vim.schedule_wrap(function(result)
			vim.system(
				{ 'jq', '-cj',
					'[ .[] | {"id": .id, "title": .title, "url": .html_url, "labels": [ .labels.[] | { "name": .name, "color": .color } ], "author": .user.login, "repository": .repository.full_name, "updated_at": .updated_at, "number": .number } ]' },
				{ stdin = result.stdout:gsub("\n", " ") }, vim.schedule_wrap(function(parsed)
					M._issues = {}
					for _, item in ipairs(vim.json.decode(parsed.stdout)) do
						item.open = opts.default_open
						item.id = tostring(item.id)
						table.insert(M._issues, item)
					end
					if _flags.n and _flags.pr then
						M.display()
						_flags.n = false
						_flags.pr = false
					else
						_flags.i = true
					end
				end))
		end))
end

M.open_item = function()
	local cursor = vim.api.nvim_win_get_cursor(0)[1]
	local type = utils.get_item_type(cursor)
	local id = utils.get_item_id(cursor)
	local item = {}
	if type == 'notification' then
		item = utils.find_by_id(M._notifications, id).n
		if item.type == "PullRequest" then
			type = "pr"
		else
			type = "issue"
		end
	elseif type == 'issue' then
		item = utils.find_by_id(M._issues, id).n
	elseif type == 'pr' then
		item = utils.find_by_id(M._pull_requests, id).n
	end
	vim.cmd("Octo " .. type .. " edit " .. item.repository .. " " .. item.number)
end

M.copy_url = function()
	local cursor = vim.api.nvim_win_get_cursor(0)[1]
	local id = utils.get_item_id(cursor)
	local type = utils.get_item_type(cursor)
	local type_list = {}
	if type == 'issue' then
		type_list = M._issues
	elseif type == 'notification' then
		type_list = M._notifications
	elseif type == 'pr' then
		type_list = M._pull_requests
	end
	local item = utils.find_by_id(type_list, id).n
	vim.cmd("let @+ = \"" .. item.url .. "\"")
	vim.notify("Copied " .. item.url .. " to clipboard", vim.log.levels.INFO)
end

M.copy_item_number = function()
	local cursor = vim.api.nvim_win_get_cursor(0)[1]
	local id = utils.get_item_id(cursor)
	local type = utils.get_item_type(cursor)
	local type_list = {}
	if type == 'issue' then
		type_list = M._issues
	elseif type == 'notification' then
		type_list = M._notifications
	elseif type == 'pr' then
		type_list = M._pull_requests
	end
	local item = utils.find_by_id(type_list, id).n
	vim.cmd("let @+ = \"" .. item.number .. "\"")
	vim.notify("Copied " .. item.number .. " to clipboard", vim.log.levels.INFO)
end

M.mark_as_read = function()
	local cursor = vim.api.nvim_win_get_cursor(0)[1]
	local type = utils.get_item_type(cursor)
	if not type == 'notification' then
		return vim.notify("Not a notification", vim.log.levels.ERROR)
	end
	local id = utils.get_item_id(cursor)
	if not id then
		return vim.notify("Not a notification", vim.log.levels.ERROR)
	end
	local url = "https://api.github.com/notifications/threads/" .. id
	vim.system(
		{ 'curl', '-s', '-X', 'PATCH', '-H', 'Accept: application/vnd.github+json', '-H', 'Authorization: Bearer ' ..
		token, '-H', 'X-Github-Api-Version: 2022-11-28', url }, {}, vim.schedule_wrap(function()
			vim.notify("Notification " .. id .. " marked as read")
			_flags.pr = true
			_flags.i = true
			M.get_notifications()
		end))
end

M.open_in_browser = function()
	local cursor = vim.api.nvim_win_get_cursor(0)[1]
	local id = utils.get_item_id(cursor)
	local type = utils.get_item_type(cursor)
	local type_list = {}
	if type == 'issue' then
		type_list = M._issues
	elseif type == 'notification' then
		type_list = M._notifications
	elseif type == 'pr' then
		type_list = M._pull_requests
	end
	local item = utils.find_by_id(type_list, id).n
	vim.cmd("silent exec '!open \"" .. item.url .. "\"'")
end

M.refresh = function()
	M.get_notifications()
	M.get_issues()
	M.get_pull_requests()
	vim.notify("Ready", vim.log.levels.INFO)
	M.display()
end

M.start_loop = function()
	utils.set_interval(3600000, function()
		vim.system({ 'sh', '/home/lucas/.config/scripts/github/notifier.sh' })
		M.refresh()
	end)
end

M.open = function()
	local bufnr = vim.api.nvim_create_buf(false, true)
	require("octo.model.octo-buffer").OctoBuffer:new { bufnr = bufnr }
	vim.api.nvim_buf_set_name(bufnr, "GHN")
	vim.api.nvim_set_option_value("filetype", "GHN", { buf = bufnr })
	vim.api.nvim_win_set_buf(0, bufnr)
	vim.keymap.set({ "n" }, "<CR>", M.toggle_item, { buffer = bufnr, noremap = true })
	vim.keymap.set({ "v" }, "<CR>", M.toggle_multiple_items, { buffer = bufnr, noremap = true })
	vim.keymap.set({ "n" }, opts.mappings.toggle_item, M.toggle_item, { buffer = bufnr, noremap = true })
	vim.keymap.set({ "v" }, opts.mappings.toggle_item, M.toggle_multiple_items, { buffer = bufnr, noremap = true })
	vim.keymap.set({ "n", "v" }, opts.mappings.open_item, M.open_item, { buffer = bufnr, noremap = true })
	vim.keymap.set({ "n", "v" }, opts.mappings.refresh, M.refresh, { buffer = bufnr, noremap = true })
	vim.keymap.set({ "n", "v" }, opts.mappings.close_all, M.close_all, { buffer = bufnr, noremap = true })
	vim.keymap.set({ "n" }, opts.mappings.copy_url, M.copy_url, { buffer = bufnr, noremap = true })
	vim.keymap.set({ "n" }, opts.mappings.copy_number, M.copy_item_number, { buffer = bufnr, noremap = true })
	vim.keymap.set({ "n" }, opts.mappings.mark_as_read, M.mark_as_read, { buffer = bufnr, noremap = true })
	vim.keymap.set({ "n" }, opts.mappings.open_in_browser, M.open_in_browser, { buffer = bufnr, noremap = true })
	M.refresh()

	vim.api.nvim_create_autocmd("CursorHold", {
		group = augroup,
		buffer = bufnr,
		callback = require "octo".on_cursor_hold
	})
end

M.setup = function(setup_opts)
	if setup_opts then
		for key in pairs(default_opts) do
			if setup_opts[key] then
				opts[key] = setup_opts[key]
			else
				opts[key] = default_opts[key]
			end
		end
	end
	vim.api.nvim_create_autocmd("VimEnter",
		{
			group = augroup,
			desc = "GitHub Notifications",
			once = true,
			callback = function()
				vim.keymap.set({ "n", "v" }, "<leader>gn", M.start,
					{ desc = "[G]ithub [N]otifications", noremap = true, silent = true })
			end
		})
end

return M
