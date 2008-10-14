function! Search(args)
    execute "silent! grep " . a:args
    botright copen
endfunction

command! -nargs=* -complete=file Search call Search(<q-args>)
