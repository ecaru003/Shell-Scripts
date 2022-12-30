"####################################################
"############ DEFAULT CONFIG
execute pathogen#infect()
syntax on                       "interpret words as code
set tabstop=4                   " set tab size
filetype on                     " filetype detection
set nocompatible                "remove compatibility with vi
set number                      "print line number on left

set hlsearch                    "highlights during search
set wildmenu                    "enable auto completion with tab in menu
set wildmode=list:longest       "option to make wildmode behave like bash (apparently)

set laststatus=2                "enable status line
hi StatusLine ctermbg=white ctermfg=136                                                                 "sets status line to gold, characters to white
"set spell spelllang=en_us
filetype plugin indent on
set backspace=indent,eol,start


"################################################
"########### FUNCTIONS
function! WordCount()
   let s:old_status = v:statusmsg
   let position = getpos(".")
   exe ":silent normal g\<c-g>"
   let stat = v:statusmsg
   let s:word_count = 0
   if stat != '--No lines in buffer--'
     let s:word_count = str2nr(split(v:statusmsg)[11])
     let v:statusmsg = s:old_status
   end
   call setpos('.', position)
   return s:word_count
endfunction
set statusline=%{WordCount()}\ words\ %{wordcount().chars}\ characters  "set word count and character count in status



"####################################################################
"######### PLUGIN MANAGER

