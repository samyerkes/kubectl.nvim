local kubectl = {}

local function with_defaults(options)
	return {
		extension = options.extension or "yaml"
	}
end

-- This function is supposed to be called explicitly by users to configure this
-- plugin
function kubectl.setup(options)
	-- avoid setting global values outside of this function. Global state
	-- mutations are hard to debug and test, so having them in a single
	-- function/module makes it easier to reason about all possible changes
	kubectl.options = with_defaults(options)

	-- do here any startup your plugin needs, like creating commands and
	-- mappings that depend on values passed in options
	vim.api.nvim_create_user_command("KubectlApply", kubectl.apply, {})
	vim.api.nvim_create_user_command("KubectlCreate", kubectl.create, {})
	vim.api.nvim_create_user_command("KubectlDelete", kubectl.delete, {})
end

function kubectl.is_configured()
	return kubectl.options ~= nil
end

-- Apply a Kubernetes manifest
function kubectl.apply()
	if not kubectl.is_configured() then
		return
	end

	local buffer = vim.fn.expand("%")
	if string.match(buffer, ".yaml$") or string.match(buffer, ".yml$") then
		local cmd = "kubectl apply "
		if string.match(buffer, "kustomization.yaml$") then
			-- kustomizations can only be applied from the directory
			-- so we need to remove the filename from the buffer
			buffer = string.gsub(buffer, "kustomization.yaml$", "")
			cmd = cmd .. "-k " .. buffer
		else
			cmd = cmd .. "-f " .. buffer
		end
		vim.cmd("!" .. cmd)
	else
		print("ERROR: Can not apply " .. buffer .. " because it does not end in .yaml or .yml")
	end
end

-- Create a new Kubernetes object manifest
function kubectl.create()
	if not kubectl.is_configured() then
		return
	end

	local args = {}
	local title = "Creating a new Kubernetes object manifest"
	local type = vim.fn.input(title .. "\ntype: ")
	local name = vim.fn.input("name: ")
	local command = ""
	local cmd = "!kubectl "

	if string.match(type, "po") then
		cmd = cmd .. "run"
	else
		cmd = cmd .. "create " .. type
	end

	-- define the namespace for everything except namespaces
	local namespace = ""
	if type ~= "namespace" and type ~= "ns" then
		namespace = vim.fn.input("namespace: ")
	end
	if namespace ~= "" then
		cmd = cmd .. " --namespace=" .. namespace
	end

	-- define which flags are required per object type
	local ktype = {}
	ktype["cm"] = { {}, true }
	ktype["configmap"] = { {}, true }
	ktype["deployment"] = { { "image", "replicas", "port" }, false }
	ktype["po"] = { { "image", "port" }, false }
	ktype["pod"] = { { "image", "port" }, false }

	-- add the individual flags to the command
	if ktype[type] ~= nil then
		for k, v in pairs(kubectl.flag(ktype[type][1], ktype[type][2])) do
			table.insert(args, v)
		end
	end

	-- pods can have an additional command on the end of the run
	-- but it has to come after the dry-run and output flags
	if string.match(type, "po") then
		command = vim.fn.input("command: ")
		command = " -- " .. command
	end

	local filename = vim.fn.input("filename: ")

	cmd = cmd .. " " .. name .. " " ..
	    table.concat(args, " ") .. " --dry-run=client -o yaml > " .. filename .. command

	vim.cmd(cmd)
end

function kubectl.flag(flags, freeformOpts)
	local args = {}
	for _, flag in ipairs(flags) do
		local value = vim.fn.input(flag .. ": ")
		if value ~= "" then
			local myflag = "--" .. flag .. "=" .. value
			table.insert(args, myflag)
		end
	end
	if freeformOpts then
		local extraflags = vim.fn.input("additional flags: ")
		table.insert(args, extraflags)
	end
	return args
end

-- Delete a Kubernetes object
function kubectl.delete()
	if not kubectl.is_configured() then
		return
	end
	local title = "WARNING: This will delete the object from the cluster"
	local type = vim.fn.input(title .. "\ntype: ")
	local object = vim.fn.input("name: ")
	vim.cmd("!" .. "kubectl delete " .. type .. " " .. object)
end

-- Key mappings
vim.keymap.set('n', '<leader>ka', kubectl.apply, { desc = '[k]ubectl [a]pply' })
vim.keymap.set('n', '<leader>kc', kubectl.create, { desc = '[k]ubectl [c]reate' })
vim.keymap.set('n', '<leader>kd', kubectl.delete, { desc = '[k]ubectl [d]elete' })

kubectl.options = nil
return kubectl
