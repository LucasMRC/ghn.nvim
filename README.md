# GHN.nvim

![image](https://github.com/user-attachments/assets/03b1f096-8d97-4d34-9e3f-12e0c97de30a)

This started as a simple way to visualize and manage Github
notifications at my job. I added assigned issues and opened PRs for convenience.

I am completely new to Lua and Neovim, so this might not be the best code you've
ever seen. But I couln't find a plugin that did what I wanted, so I decided to make my own.

## Dependencies
[Octo.nvim](https://github.com/pwntester/octo.nvim) is used to manage PRs and issues.

## Installation

You can install this plugin using your favorite plugin manager. I use `lazy.nvim`, so

```lua
{
	'lucasMRC/ghn.nvim',
	dependencies = {
		'pwntester/octo.nvim',
	},
	config = function()
		require("ghn").setup()
	end,
}
```

## How it works

In order to be able to use this plugin, you need to create a Github token.
You can do this by going to your Github settings, Developer settings, Personal access
tokens, and then generate a new token. You need to give it the `notifications` and
`repo` scopes.

On first start, it will prompt you to enter your token, and it will save it in a file locally.
I still haven't worked on a better way to handle this, but you now this is good enough for my
personal use.

## Configuration

So far, the only configuration keys are:

```lua
{
	mappings = {
		open_item = "O",            -- mapping to open the item in Octo
		refresh = "R",              -- mapping to refresh the notifications
		copy_url = "Y",             -- mapping to copy the URL of the item
		copy_number = "<C-y>",      -- mapping to copy the item number
		mark_as_read = "<C-r>",     -- mapping to mark the notification as read
		open_in_browser = "<C-o>",  -- mapping to open the item in the browser
	}
}
```
