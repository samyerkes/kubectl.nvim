local K = {}

function K.setup(opts)
	opts = opts or {}

	local kubectlApply = function()
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

	vim.keymap.set('n', '<leader>ka', kubectlApply, { desc = '[k]ubectl [a]pply' })

	local kubectlDelete = function()
		local kubeObject = vim.fn.input("> kubectl delete ")
		vim.cmd("!" .. "kubectl delete " .. kubeObject)
	end

	vim.keymap.set('n', '<leader>kd', kubectlDelete, { desc = '[k]ubectl [d]elete' })
end

return K
