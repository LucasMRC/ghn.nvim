vim.cmd.syntax([[match GhnTitle 'Github Dashboard']])
vim.cmd.syntax([[match GhnTotal '(\d*)']])
vim.cmd.syntax([[match NotType '. \%\[\(Issue\|PullRequest\|Commit\) \]#\d*']])
vim.cmd.syntax([[match NotTitle '- .* \['ms=s+2,me=e-1]])
vim.cmd.syntax([[match NotNumber '\[\(N\|I\|PR\)\.id \d*\]']])
vim.cmd.syntax([[match NotValue ': .*'ms=s+2]])
vim.cmd.syntax([[match NotLabel ' \(Repo\|Reason\|Updated\|Url\|Tags\|Author\):'ms=s+1,me=e-1]])
vim.cmd.syntax([[match NotIndent '\t| 'ms=s+1,me=e-1]])
vim.cmd.syntax([[match NotUrl 'https:\/\/github.com\/.*\/\(pull\|issues\)\/\d*']])

vim.api.nvim_command('hi GhnTitle guifg=#e4e4e4 gui=bold,underline')
vim.api.nvim_command('hi GhnTotal guifg=#e4e4e4 gui=italic')
vim.api.nvim_command('hi NotType guifg=#afd7ff')
vim.api.nvim_command('hi NotIndent guifg=#afd7ff')
vim.api.nvim_command('hi NotTitle guifg=#c0c0c0 gui=italic')
vim.api.nvim_command('hi NotNumber guifg=#808080')
vim.api.nvim_command('hi NotUrl guifg=#d7d7ff gui=italic,underline')
vim.api.nvim_command('hi NotValue guifg=#d7d7ff')
vim.api.nvim_command('hi NotLabel gui=underline')
