-- Simple git log graph mapping
vim.keymap.set('n', '<leader>gl', function()
  -- Create floating window (same total width as git status interface)
  local single_width = math.floor(vim.o.columns * 0.4)
  local width = single_width * 2 + 2  -- Match git status total width
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Git Log Graph ',
    title_pos = 'center'
  })

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)

  -- Close with q or Escape
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<cr>', { silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<cr>', { silent = true })

  -- Start terminal with pager disabled
  local cmd = {
    "git", "--no-pager", "log", "--graph",
    "--pretty=format:%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset",
    "--abbrev-commit"
  }
  -- Set environment to disable pager completely
  vim.fn.termopen(cmd, {
    cwd = vim.fn.getcwd(),
    env = { GIT_PAGER = '', PAGER = '', LESS = '' }
  })
end, { desc = 'Git Log Graph' })

-- Return empty table since we're just setting a keymap
return {}
