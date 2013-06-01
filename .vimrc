
set backspace=2         " backspace in insert mode works like normal editor
syntax on               " syntax highlighting
filetype indent on      " activates indenting for files
set autoindent          " auto indenting
set number              " line numbers
set nobackup            " get rid of anoying ~file

set mouse=a

execute pathogen#infect()
filetype plugin indent on

" auto open nerdtree when no params
autocmd vimenter * if !argc() | NERDTree | endif

" :Q really closes everything
command Q qa
colorscheme desert      " colorscheme desert

" smart case sensitivity search
set ignorecase
set smartcase

" color column
set colorcolumn=100

" tabs to spaces
set expandtab
set tabstop=2
set shiftwidth=2

" show and remove trailing whitespace on write
autocmd BufWritePre * :%s/\s\+$//e
:highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
autocmd FileType py setlocal colorcolumn=80
autocmd FileType builddefs setlocal colorcolumn=80
autocmd FileType proto setlocal colorcolumn=80
autocmd FileType javascript setlocal colorcolumn=80
autocmd FileType soy setlocal colorcolumn=80



"===========================================
" perforce commands
command! -nargs=* -complete=file PEdit :!g4 edit %

function! s:CheckOutFile()
 if filereadable(expand("%")) && ! filewritable(expand("%"))
   let s:pos = getpos('.')
   let option = confirm("Readonly file, do you want to checkout from p4?"
         \, "&Yes\n&No", 1, "Question")
   if option == 1
     PEdit
   endif
   edit!
   call cursor(s:pos[1:3])
 endif
endfunction
au FileChangedRO * nested :call <SID>CheckOutFile()
