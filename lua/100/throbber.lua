local active_throbbers = {}

local function create_throbber(buf, rowstart, colstart, rowend, colend, replacementCallback)
	local iteration = 1

	-- Setup marks
	local chars = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
	local namespace = vim.api.nvim_create_namespace('100')
	local mark1 = vim.api.nvim_buf_set_extmark(buf, namespace, rowstart-1,  0, {hl_group='Comment',virt_lines_above=true,right_gravity=false,virt_text={{''}},virt_lines={{{chars[iteration] .. ' Implementing'}}}})
	local mark2 =	vim.api.nvim_buf_set_extmark(buf, namespace, rowend  -0, -0, {hl_group='Comment',virt_lines_above=true,right_gravity=false,virt_text={{''}},virt_lines={{{chars[iteration] .. ' Implementing'}}}})

	-- Setup and run throbber animation
	local updateInterval = require('100.timer').setInterval(150, function()
		iteration = iteration % #chars + 1

		local mark1data = vim.api.nvim_buf_get_extmark_by_id(buf, namespace, mark1, {details=true})
		local mark2data = vim.api.nvim_buf_get_extmark_by_id(buf, namespace, mark2, {details=true})

		print(mark1data[1],mark1data[2])
		vim.api.nvim_buf_set_extmark(buf, namespace, mark1data[1], mark1data[2], {id=mark1,virt_lines_above=true,right_gravity=true,virt_text={{''}},virt_lines={{{chars[iteration] .. ' Implementing'}}}})
		vim.api.nvim_buf_set_extmark(buf, namespace, mark2data[1], mark2data[2], {id=mark2,virt_lines_above=true,right_gravity=false,virt_text={{''}},virt_lines={{{chars[iteration] .. ' Implementing'}}}})
	end)

	-- Run user defined replacementCallback immediatly with resolve and reject callbacks. if replacementCallback calls the resolve function, the content of the trobber will be replaced
	replacementCallback(function(content)
			vim.schedule(function()
				require('100.timer').clearInterval(updateInterval)

				local mark1data = vim.api.nvim_buf_get_extmark_by_id(buf, namespace, mark1, {details=true})
				local mark2data = vim.api.nvim_buf_get_extmark_by_id(buf, namespace, mark2, {details=true})

				vim.api.nvim_buf_set_text(buf, mark1data[1], mark1data[2], mark2data[1], mark2data[2], vim.fn.split(content, '\n', true))

				vim.api.nvim_buf_del_extmark(buf, namespace, mark1)
				vim.api.nvim_buf_del_extmark(buf, namespace, mark2)
			end)
		end, 
		function()
			vim.schedule(function()
				require('100.timer').clearInterval(updateInterval)

				vim.api.nvim_buf_del_extmark(buf, namespace, mark1)
				vim.api.nvim_buf_del_extmark(buf, namespace, mark2)
			end)
		end)
end

return {
	create_throbber = create_throbber
}
