local M = {}

M.get_line_text = function(ln)
	return vim.api.nvim_buf_get_lines(0, ln - 1, ln, true)[1]
end

M.prompt_for_token = function(path)
	local input = vim.fn.input({ prompt = "Enter token: " })
	local f = assert(io.open(path .. "/ghn.pass", "w"))
	f:write(input)
	f:close()
	return input
end

M.get_item_id = function(ln)
	local line = M.get_line_text(ln)
	if ln == 1 or line == "" or line:find("[NAO].* %(%d+%)$") then
		return
	end
	while line:match("%[[NIPR]*%.id (%d+)%]$") == nil do
		ln = ln - 1
		line = M.get_line_text(ln)
	end
	return line:gsub(".* %[[NIPR]*%.id (%d+)%]$", "%1")
end

M.get_item_type = function(ln)
	local line = M.get_line_text(ln)
	if ln == 1 or line == "" or line:find("[NAO].* %(%d+%)$") then
		return
	end
	while line:match("%[[NIPR]*%.id %d+%]$") == nil do
		ln = ln - 1
		line = M.get_line_text(ln)
	end
	local raw_type = line:gsub(".* %[([NIPR]*)%.id %d+%]$", "%1")
	if raw_type == "I" then
		return "issue"
	elseif raw_type == "N" then
		return "notification"
	elseif raw_type == "PR" then
		return "pr"
	end
end

M.get_multiple_item_ids = function()
	local esc = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
	vim.api.nvim_feedkeys(esc, 'x', false)
	local first = vim.api.nvim_buf_get_mark(0, '<')[1]
	if first <= 3 then
		return
	end
	while M.get_item_id(first) == nil do
		first = first - 1
	end
	local last = vim.api.nvim_buf_get_mark(0, '>')[1]
	while M.get_item_id(last) == nil do
		last = last - 1
	end
	if first > last then
		local temp = last
		last = first
		first = temp
	end
	local present = {}
	for i = 0, last - first do
		local id = M.get_item_id(first + i)
		if id and not present[id] then
			present[id] = M.get_item_type(first + i)
		end
	end
	local ids = {}
	for i, t in pairs(present) do
		table.insert(ids, { id = i, type = t })
	end

	return ids
end

M.find_by_id = function(list, id)
	local r = {}
	for i, n in ipairs(list) do
		if n.id == id then
			r = { n = n, i = i }
			break
		end
	end
	return r
end

M.set_interval = function(interval, callback)
	local timer = vim.uv.new_timer()
	timer:start(1000, interval, vim.schedule_wrap(callback))
end

return M
