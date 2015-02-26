set nocompatible

" --- General settings ---
set backspace=indent,eol,start

"Display line/column number in bottom left
set ruler

set showcmd

"Highlight as you type pattern
set incsearch

"Highlight search
set hlsearch

"enable the mouse
set mouse=a

" Display cursor line highlight
set cursorline

" Load pathogen plugins
execute pathogen#infect()

syntax on

filetype plugin indent on

syntax enable

" Solarized stuff
set background=dark
let g:solarized_termtrans=1
colorscheme solarized

let g:airline_powerline_fonts = 1
let g:airline_theme='dark'

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

set laststatus=2
