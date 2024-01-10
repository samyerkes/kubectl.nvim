# kubectl.nvim

A simple plugin to apply and delete Kuberenetes objects directly from Neovim.

* `<leader>ka` will apply the current .yaml (or .yml) file to the cluster.
* `<leader>kc` will create a prompt you through creating a new manifest.
* `<leader>kd` will create a prompt to delete any item from the cluster.

You can also additionally use the following commands:

```vim
:KubectlApply
:KubectlCreate
:KubectlDelete
```

## Motivation

I got tired of switching windows when authoring Kubernetes resources.

## Installation

With the Lazy package manager:

```lua
  -- Kubectl plugin
  {
    "samyerkes/kubectl.nvim",
    opts = {}
  },
```
