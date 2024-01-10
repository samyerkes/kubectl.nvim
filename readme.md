# kubectl.nvim

A simple plugin to apply and delete Kuberenetes objects directly from Neovim.

* `<leader>ka` will apply the current .yaml (or .yml) file to the cluster.
* `<leader>kd` will create a prompt to delete any item from the cluster.

## Motivation

I got tired of switching windows when authoring Kubernetes resources.
