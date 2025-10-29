-- Floating terminal window
local function open_floating_terminal()
  -- Calculate window size (same as git status total width for consistency)
  local single_width = math.floor(vim.o.columns * 0.4)
  local width = single_width * 2 + 2  -- Match git status total width
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create terminal buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Terminal ',
    title_pos = 'center'
  })

  -- Start terminal with optimized configuration
  local env = {
    SHELL = vim.o.shell,  -- Preserve user's shell choice
    GIT_PAGER = '',  -- Disable git pager to prevent stuck less processes
    PAGER = '',  -- Disable general pager
    LESS = ''  -- Disable less environment
  }

  vim.fn.termopen(vim.o.shell, {
    env = env,
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  })  -- Enter insert mode in terminal
  vim.cmd('startinsert')

  -- Add quit mapping for normal mode in terminal
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
    silent = true
  })

  -- Add escape mapping to exit terminal mode
  vim.api.nvim_buf_set_keymap(buf, 't', '<Esc>', '<C-\\><C-n>', { silent = true })
end

-- Set up keymap
vim.keymap.set('n', '<leader>t', open_floating_terminal, { desc = 'Floating Terminal' })

-- Return empty table for module loading
return {}
