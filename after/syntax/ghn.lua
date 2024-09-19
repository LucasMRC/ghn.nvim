vim.cmd.syntax([[match GHNTitle 'Github Dashboard']])
vim.cmd.syntax([[match GHNTotal '(\d*)']])
vim.cmd.syntax([[match GHNNotificationTitle ') - .* \['ms=s+2,me=e-2]])
vim.cmd.syntax([[match GHNNotificationNumber '\[\(N\|I\|PR\)\.id \d*\]']])
vim.cmd.syntax([[match GHNNotificationTypePR 'PullRequest:' conceal cchar=󰘬 ]])
vim.cmd.syntax([[match GHNNotificationTypeIssue 'Issue:' conceal cchar= ]])
vim.cmd.syntax([[match GHNNotificationTypeCommit 'Commit:' conceal cchar= ]])
vim.cmd.syntax([[match GHNHeading '\(Notifications\|Assigned Issues\|Opened PRs\)']])
vim.cmd.syntax([[match GHNIssuePattern '\(.*#\d*\)' conceal cchar=□]])

vim.api.nvim_command('hi GHNTitle guifg=#e4e4e4 gui=bold,underline')
vim.api.nvim_command('hi GHNTotal guifg=#e4e4e4 gui=italic')
vim.api.nvim_command('hi GHNNotificationTitle guifg=#c0c0c0 gui=italic')
vim.api.nvim_command('hi GHNNotificationTypePR guifg=#afd7ff')
vim.api.nvim_command('hi GHNNotificationTypeCommit guifg=#afd7ff')
vim.api.nvim_command('hi GHNNotificationTypeIssue guifg=#afd7ff')
vim.api.nvim_command('hi GHNNotificationNumber guifg=#808080')
vim.api.nvim_command('hi GHNHeading guifg=#d7d7ff gui=underline')
