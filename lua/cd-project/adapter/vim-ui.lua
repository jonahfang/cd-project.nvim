local api = require("cd-project.api")
local config = require("cd-project.config")
local function logErr(msg)
	vim.notify(msg, vim.log.levels.ERROR, { title = "cd-project.nvim" })
end

-- TODO: how to make this level purely to get user input and pass to the api functions
local function cd_project()
    if config.config.before_switch_project then
        local ok = config.config.before_switch_project()
        if not ok then
            return
        end
    end
	vim.ui.select(config.get_projects(), {
        format_item = function(item)
            if config.config.format_project_path then
                return config.config.format_project_path(item.path,item.name)
            else
                return item
            end
        end,
	}, function(selected)
		if not selected then
			return
		end
		api.cd_project(selected.path)
	end)
end

return {
	cd_project = cd_project,
}
