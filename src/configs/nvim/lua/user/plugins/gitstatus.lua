-- Enhanced git status with better navigation and staging
local function git_enhanced_status()
  -- Create left window for file list
  local width = math.floor(vim.o.columns * 0.4)
  local height = math.floor(vim.o.lines * 0.8)
  local total_width = width * 2 + 2  -- Two windows plus gap
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - total_width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'gitfiles')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Git Files ',
    title_pos = 'center'
  })

  -- Create right window for diff
  local diff_col = col + width + 2
  local diff_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(diff_buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(diff_buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(diff_buf, 'filetype', 'diff')
  vim.api.nvim_buf_set_option(diff_buf, 'swapfile', false)

  local diff_win = vim.api.nvim_open_win(diff_buf, false, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = diff_col,
    style = 'minimal',
    border = 'rounded',
    title = ' Git Diff ',
    title_pos = 'center'
  })

  -- Get git status and build file list
  local handle = io.popen('git status --porcelain')
  local result = handle:read('*all')
  handle:close()

  if result == '' then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {'No changes to display'})
    return
  end

  local files = {}
  local lines = {}
  for line in result:gmatch('[^\r\n]+') do
    local status = line:sub(1, 2)
    local file = line:sub(4)
    table.insert(files, {status = status, file = file})

    -- Add icon based on staging status
    -- First char: staging area, Second char: working tree
    -- For untracked files: both chars are '?'
    local first_char = status:sub(1, 1)
    local second_char = status:sub(2, 2)

    local icon
    if first_char == '?' then
      -- Untracked files are never staged
      icon = '○ '
    elseif first_char ~= ' ' then
      -- Something in staging area
      icon = '✓ '
    else
      -- Nothing in staging area
      icon = '○ '
    end

    local status_text = ''
    if first_char == 'M' or second_char == 'M' then status_text = '[M] ' end
    if first_char == 'A' or second_char == 'A' then status_text = '[A] ' end
    if first_char == 'D' or second_char == 'D' then status_text = '[D] ' end
    if first_char == '?' then status_text = '[?] ' end

    table.insert(lines, icon .. status_text .. file)
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  -- Set up syntax highlighting for colors
  vim.api.nvim_buf_call(buf, function()
    vim.cmd('syntax clear')

    -- Try to use text-only highlight groups instead of diff groups
    -- These groups are more likely to have proper foreground colors
    local function get_hl_color(hl_group, fallback)
      local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_group })
      if ok and hl.fg then
        return string.format('#%06x', hl.fg)
      end
      return fallback
    end

    -- Staged files (green ✓) - try various green highlight groups
    vim.cmd('syntax match GitStaged "^✓" containedin=ALL')
    local staged_color = get_hl_color('String', get_hl_color('Function', '#00ff00'))
    vim.cmd('highlight GitStaged ctermfg=2 ctermbg=NONE guifg=' .. staged_color .. ' guibg=NONE')

    -- Unstaged files (red ○) - try error/warning highlight groups
    vim.cmd('syntax match GitUnstaged "^○" containedin=ALL')
    local unstaged_color = get_hl_color('ErrorMsg', get_hl_color('Error', '#ff5555'))
    vim.cmd('highlight GitUnstaged ctermfg=1 ctermbg=NONE guifg=' .. unstaged_color .. ' guibg=NONE')

    -- Status indicators with theme foreground colors only
    vim.cmd('syntax match GitModified "\\[M\\]" containedin=ALL')
    local modified_color = get_hl_color('WarningMsg', get_hl_color('Type', '#ffff00'))
    vim.cmd('highlight GitModified ctermfg=3 ctermbg=NONE guifg=' .. modified_color .. ' guibg=NONE')

    vim.cmd('syntax match GitAdded "\\[A\\]" containedin=ALL')
    vim.cmd('highlight GitAdded ctermfg=2 ctermbg=NONE guifg=' .. staged_color .. ' guibg=NONE')

    vim.cmd('syntax match GitDeleted "\\[D\\]" containedin=ALL')
    vim.cmd('highlight GitDeleted ctermfg=1 ctermbg=NONE guifg=' .. unstaged_color .. ' guibg=NONE')

    vim.cmd('syntax match GitUntracked "\\[?\\]" containedin=ALL')
    local untracked_color = get_hl_color('Comment', '#6699cc')
    vim.cmd('highlight GitUntracked ctermfg=6 ctermbg=NONE guifg=' .. untracked_color .. ' guibg=NONE')

    -- File names - use normal text color
    vim.cmd('syntax match GitFileName " [^ ]*$" containedin=ALL')
    local normal_color = get_hl_color('Normal', '#ffffff')
    vim.cmd('highlight GitFileName ctermfg=7 ctermbg=NONE guifg=' .. normal_color .. ' guibg=NONE')
  end)

  -- Helper functions
  local function get_current_file()
    local current_line = vim.api.nvim_win_get_cursor(win)[1]
    return files[current_line]
  end

  local function show_diff()
    local file_info = get_current_file()
    if file_info then
      local diff_cmd = 'git diff HEAD -- ' .. vim.fn.shellescape(file_info.file)
      local diff_output = vim.fn.system(diff_cmd)
      local diff_lines = vim.split(diff_output, '\n')
      vim.api.nvim_buf_set_option(diff_buf, 'modifiable', true)
      vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, diff_lines)
      vim.api.nvim_buf_set_option(diff_buf, 'modifiable', false)
      vim.api.nvim_buf_set_option(diff_buf, 'filetype', 'diff')
    end
  end

  local function refresh_status()
    -- Remember current cursor position
    local current_line = vim.api.nvim_win_get_cursor(win)[1]
    local current_file = files[current_line] and files[current_line].file

    -- Get updated git status
    local handle = io.popen('git status --porcelain')
    local result = handle:read('*all')
    handle:close()

    if result == '' then
      vim.api.nvim_buf_set_option(buf, 'modifiable', true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {'No changes to display'})
      vim.api.nvim_buf_set_option(buf, 'modifiable', false)
      return
    end

    -- Rebuild files list and lines
    files = {}
    local lines = {}
    for line in result:gmatch('[^\r\n]+') do
      local status = line:sub(1, 2)
      local file = line:sub(4)
      table.insert(files, {status = status, file = file})

      -- Add icon based on staging status
      local first_char = status:sub(1, 1)
      local second_char = status:sub(2, 2)

      local icon
      if first_char == '?' then
        icon = '○ '
      elseif first_char ~= ' ' then
        icon = '✓ '
      else
        icon = '○ '
      end

      local status_text = ''
      if first_char == 'M' or second_char == 'M' then status_text = '[M] ' end
      if first_char == 'A' or second_char == 'A' then status_text = '[A] ' end
      if first_char == 'D' or second_char == 'D' then status_text = '[D] ' end
      if first_char == '?' then status_text = '[?] ' end

      table.insert(lines, icon .. status_text .. file)
    end

    -- Update buffer content
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    -- Try to restore cursor position to the same file
    if current_file then
      for i, file_info in ipairs(files) do
        if file_info.file == current_file then
          vim.api.nvim_win_set_cursor(win, {i, 0})
          break
        end
      end
    end

    -- Update diff for current file
    show_diff()
  end

  -- Show initial diff
  show_diff()

  -- Navigation mappings
  vim.api.nvim_buf_set_keymap(buf, 'n', 'j', '', {
    callback = function()
      vim.cmd('normal! j')
      show_diff()
    end,
    silent = true
  })
  vim.api.nvim_buf_set_keymap(buf, 'n', 'k', '', {
    callback = function()
      vim.cmd('normal! k')
      show_diff()
    end,
    silent = true
  })

  -- Window navigation
  vim.api.nvim_buf_set_keymap(buf, 'n', 'l', '', {
    callback = function() vim.api.nvim_set_current_win(diff_win) end,
    silent = true
  })
  vim.api.nvim_buf_set_keymap(diff_buf, 'n', 'h', '', {
    callback = function() vim.api.nvim_set_current_win(win) end,
    silent = true
  })

  -- Toggle stage/unstage file with 'a'
  vim.api.nvim_buf_set_keymap(buf, 'n', 'a', '', {
    callback = function()
      local file_info = get_current_file()
      if file_info then
        local first_char = file_info.status:sub(1, 1)

        if first_char == '?' then
          -- Untracked file - stage it
          vim.fn.system('git --no-pager add ' .. vim.fn.shellescape(file_info.file))
        elseif first_char ~= ' ' then
          -- Staged file - unstage it
          vim.fn.system('git --no-pager reset HEAD ' .. vim.fn.shellescape(file_info.file))
        else
          -- Unstaged file - stage it
          vim.fn.system('git --no-pager add ' .. vim.fn.shellescape(file_info.file))
        end

        refresh_status()
      end
    end,
    silent = true
  })

  -- Commit with 'c'
  vim.api.nvim_buf_set_keymap(buf, 'n', 'c', '', {
    callback = function()
      -- Create commit message floating window
      local commit_width = 60
      local commit_height = 5
      local commit_row = math.floor((vim.o.lines - commit_height) / 2)
      local commit_col = math.floor((vim.o.columns - commit_width) / 2)

      local commit_buf = vim.api.nvim_create_buf(false, true)
      local commit_win = vim.api.nvim_open_win(commit_buf, true, {
        relative = 'editor',
        width = commit_width,
        height = commit_height,
        row = commit_row,
        col = commit_col,
        style = 'minimal',
        border = 'rounded',
        title = ' Commit Message ',
        title_pos = 'center'
      })

      vim.api.nvim_buf_set_option(commit_buf, 'buftype', 'nofile')
      vim.api.nvim_buf_set_lines(commit_buf, 0, -1, false, {'', 'Enter your commit message above', 'Press <Enter> to commit, <Esc> to cancel'})
      vim.api.nvim_win_set_cursor(commit_win, {1, 0})
      vim.cmd('startinsert')

      -- Commit on Enter
      vim.api.nvim_buf_set_keymap(commit_buf, 'i', '<CR>', '', {
        callback = function()
          local lines = vim.api.nvim_buf_get_lines(commit_buf, 0, 1, false)
          local message = lines[1] or ''
          if message ~= '' then
            local result = vim.fn.system('git --no-pager commit -m ' .. vim.fn.shellescape(message))
            print('\n' .. result)
            vim.api.nvim_win_close(commit_win, true)
            refresh_status()
          end
        end,
        silent = true
      })

      -- Cancel on Escape
      vim.api.nvim_buf_set_keymap(commit_buf, 'i', '<Esc>', '', {
        callback = function()
          vim.api.nvim_win_close(commit_win, true)
        end,
        silent = true
      })
    end,
    silent = true
  })

  -- Close with q or Escape
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
    callback = function()
      if vim.api.nvim_win_is_valid(diff_win) then
        vim.api.nvim_win_close(diff_win, true)
      end
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
    silent = true
  })

  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
    callback = function()
      if vim.api.nvim_win_is_valid(diff_win) then
        vim.api.nvim_win_close(diff_win, true)
      end
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
    silent = true
  })

  -- Also add quit mapping to diff window
  vim.api.nvim_buf_set_keymap(diff_buf, 'n', 'q', '', {
    callback = function()
      if vim.api.nvim_win_is_valid(diff_win) then
        vim.api.nvim_win_close(diff_win, true)
      end
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
    silent = true
  })

  vim.api.nvim_buf_set_keymap(diff_buf, 'n', '<Esc>', '', {
    callback = function()
      if vim.api.nvim_win_is_valid(diff_win) then
        vim.api.nvim_win_close(diff_win, true)
      end
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
    silent = true
  })

  -- Override :q command for both buffers to close both windows
  local close_both_windows = function()
    if vim.api.nvim_win_is_valid(diff_win) then
      vim.api.nvim_win_close(diff_win, true)
    end
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  -- Set buffer-local command abbreviations for main buffer
  vim.api.nvim_buf_call(buf, function()
    vim.cmd('cnoreabbrev <buffer> q lua _G.git_status_close_windows()')
    vim.cmd('cnoreabbrev <buffer> quit lua _G.git_status_close_windows()')
  end)

  -- Set buffer-local command abbreviations for diff buffer
  vim.api.nvim_buf_call(diff_buf, function()
    vim.cmd('cnoreabbrev <buffer> q lua _G.git_status_close_windows()')
    vim.cmd('cnoreabbrev <buffer> quit lua _G.git_status_close_windows()')
  end)

  -- Store the close function globally so abbreviations can access it
  _G.git_status_close_windows = close_both_windows
end

vim.keymap.set('n', '<leader>gs', git_enhanced_status, { desc = 'Enhanced Git Status' })

-- Return empty table for module loading
return {}
