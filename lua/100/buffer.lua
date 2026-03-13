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
	return { colstart=math.min(selection.starting.x,selection.ending.x),rowstart=math.min(selection.starting.y,selection.ending.y),colend=math.max(selection.starting.x,selection.ending.x),rowend=math.max(selection.starting.y,selection.ending.y) }
	--return { starting={ x=math.min(selection.starting.x,selection.ending.x),y=math.min(selection.starting.y,selection.ending.y) },ending={ x=math.max(selection.starting.x,selection.ending.x),y=math.max(selection.starting.y,selection.ending.y) } }
end

return {
	getCursorMeta=getCursorMeta,
	getBufferContent=getBufferContent,
	getVisualContent=getVisualContent,
	getVisualContentMeta=getVisualContentMeta
}
