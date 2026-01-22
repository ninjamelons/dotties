set nocompatible
filetype on
filetype plugin on
filetype indent on

" Syntax highlighting
syntax on

" Scroll offset when reaching end of screen
set scrolloff=10
" Line numbers
set relativenumber
" Highlight line
set cursorline
" Autocomplete on tab
set wildmenu
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

set background=dark
set omnifunc=syntaxcomplete#Complete
set cot+=preview

" colorscheme desert

lua require('plugins')

" Search and replace in current folder
xnoremap <Leader>S
  \ "sy\|
  \ :silent grep <C-r>s<CR>
  \ :cfdo %s/<C-r>s//gc \| update
  \ <Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>

" Nearby search and replace
nnoremap <Leader>s :%s/<C-r><C-w>//c<Left><Left>
xnoremap <Leader>s "sy:%s/<C-r>s//c<Left><Left>
