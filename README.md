# GHN.nvim

![image](https://github.com/user-attachments/assets/61faa2e0-f40f-4447-b636-c95d4caa0192)

This started as a simple way to visualize and manage Github
notifications at my job. I added assigned issues and opened PRs for convenience.

To be completely honest, this plugin makes sense to me as most of my GH notifications
are PRs and Issues. I recently got a notification about GH actions, and I realized that
there are a lot more options than those this plugin is ready for. So, I updated a little
to be sure it does not crash on GH actions notifications, but most certainly there are
other notifications that this never took into consideration. And it may never do.

I am completely new to Lua and Neovim, so this might not be the best code you've
ever seen. But I couln't find a plugin that did what I wanted, so I decided to make my own.

## Dependencies
[Octo.nvim](https://github.com/pwntester/octo.nvim) is used to manage PRs and issues, plus this plugin inherits the popup
preview feature on cursor hold form it.

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

## Credits

This plugin was created as an extension for [Octo](https://github.com/pwntester/octo.nvim), which is the real star here.
I also came accross the [github-notifications.nvim](https://github.com/rlch/github-notifications.nvim) plugin, which looks great
and shamelessly took the time formatting from it.

Thanks to this awesome projects!
