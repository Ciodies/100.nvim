local function getCursorMeta()
	return {x=vim.fn.getpos(".")[3],y=vim.fn.getpos(".")[2]}
end

local function getBufferContent()
	return 'example file data'
end

local function getVisualContent()
	return table.concat(vim.fn.getregion(vim.fn.getpos("v"),vim.fn.getpos("."), {type=vim.fn.mode()}), "\n")
end

local function getVisualContentMeta()

	local selection = {starting={x=vim.fn.getpos("v")[3],y=vim.fn.getpos("v")[2]},ending={x=vim.fn.getpos(".")[3],y=vim.fn.getpos(".")[2]}}
	local editedselection = { colstart=math.min(selection.starting.x,selection.ending.x),rowstart=math.min(selection.starting.y,selection.ending.y),colend=math.max(selection.starting.x,selection.ending.x),rowend=math.max(selection.starting.y,selection.ending.y) }

	if vim.fn.mode() == 'V' then
		editedselection.colstart = 1
		editedselection.colend = #vim.api.nvim_buf_get_lines(0, editedselection.rowend-1, editedselection.rowend, false)[1]
	end

	return editedselection
end

return {
	getCursorMeta=getCursorMeta,
	getBufferContent=getBufferContent,
	getVisualContent=getVisualContent,
	getVisualContentMeta=getVisualContentMeta
}
