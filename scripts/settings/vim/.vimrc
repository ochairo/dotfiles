" File Encoding and Buffer Management
set fenc=utf-8                       " set file encoding to utf-8
set hidden                           " keep buffers open when closing a window

" Cursor
set cursorline                      " highlight the current line
set cursorcolumn                    " highlight the current column

" Terminal and Colors
set termguicolors                   " enable 24-bit RGB color in the terminal
colorscheme catppuccin_mocha        " set color scheme

" Visuals and Syntax
set visualbell                      " disable error bells
syntax enable                       " enable syntax highlighting

" Backup and Editing
set nowritebackup                   " disable backup files
set nobackup                        " disable backup files
set virtualedit=block               " enable block selection
set backspace=indent,eol,start      " allow backspacing over everything in insert mode
set ambiwidth=double                " set double width characters

" Search and Navigation
set wildmenu                        " enable command line completion
set ignorecase                      " ignore case when searching
set smartcase                       " ignore case when searching lowercase
set wrapscan                        " search wraps around the end of the file
set incsearch                       " show search matches as you type
set hlsearch                        " highlight search matches
set noerrorbells                    " disable error bells
set shellslash                      " use forward slashes in the shell
set showmatch matchtime=1           " show matching brackets

" Indentation and Formatting
set cinoptions+=:0                  " don't indent case statements
set smartindent                     " enable smart indent

" Interface
set cmdheight=2                     " set command line height
set laststatus=2                    " always show the status line
set showcmd                         " show command in bottom right
set display=lastline                " show as much as possible of the last line
set guioptions-=T                   " disable toolbar
set guioptions+=a                   " enable mouse
set guioptions-=m                   " disable menu
set guioptions+=R                   " enable right scrollbar
set showmatch                       " show matching brackets
set title                           " set title
set number                          " set number

" Miscellaneous
set listchars=tab:▸\-,trail:.,extends:>,precedes:<      " set list characters
set history=10000                                       " set history size
set expandtab                                           " expand tabs to spaces
set shiftwidth=2                                        " set shift width
set softtabstop=2                                       " set soft tab stop
set tabstop=2                                           " set tab stop
set noswapfile                                          " disable swap files
set nofoldenable                                        " disable folding
set clipboard=unnamed,autoselect                        " set clipboard
set nrformats=                                          " set number formats
set whichwrap=b,s,h,l,<,>,[,],~                         " set which wrap
set mouse=a                                             " enable mouse
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>                " clear search highlights
