local config = require("cd-project.config")
local function logErr(msg)
	vim.notify(msg, vim.log.levels.ERROR, { title = "cd-project.nvim" })
end

---@return string|nil
function find_project_dir()
	local found = vim.fs.find(
		config.config.project_dir_pattern,
		{ upward = true, stop = vim.loop.os_homedir(), path = vim.fs.dirname(vim.fn.expand("%:p")) }
	)

	if #found == 0 then
		return vim.loop.os_homedir()
	end

	local project_dir = vim.fs.dirname(found[1])

	if not project_dir or project_dir == "." or project_dir == "" or project_dir == " " then
		project_dir = string.match(vim.fn.execute("pwd"), "^%s*(.-)%s*$")
	end

	if not project_dir or project_dir == "." or project_dir == "" or project_dir == " " then
		return nil
	end

	return project_dir
end

---@return string[]
local function get_project_paths()
    local cwd = vim.fn.getcwd()
	local projects = config.get_projects()
	local paths = {}
	for _, value in ipairs(projects) do
       table.insert(paths, value.path)
	end
	return paths
end

---@param dir string
local function cd_project(dir)
	vim.g.cd_project_last_project = vim.g.cd_project_current_project
	vim.g.cd_project_current_project = dir
	vim.fn.execute("cd " .. dir)
    if config.config.after_switch_project then
        config.config.after_switch_project(dir)
    end
end

local function add_current_project()
	local project_dir = find_project_dir()

	if not project_dir then
		return logErr("Can't find project path of current file")
	end

	local projects = config.get_projects()

	if vim.tbl_contains(get_project_paths(), project_dir) then
		return vim.notify("Project already exists: " .. project_dir)
	end

	local new_project = {
		path = project_dir,
		name = "name place holder", -- TODO: allow user to edit the name of the project
	}
	table.insert(projects, new_project)
	config.write_projects(projects)
	vim.notify("Project added: \n" .. project_dir)
end

local function back()
	local last_project = vim.g.cd_project_last_project
	if not last_project then
		vim.notify("Can't find last project. Haven't switch project yet.")
        return
	end
	cd_project(last_project)
end

return {
	cd_project = cd_project,
	add_current_project = add_current_project,
	get_project_paths = get_project_paths,
    get_projects = get_projects,
	back = back,
	find_project_dir = find_project_dir,
}
