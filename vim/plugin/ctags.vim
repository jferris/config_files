function! CheckCtagsAge()
  if filereadable("tmp/tags") && getftime("tmp/tags") < localtime() - 86400
    echo "Tags file is out of date"
  endif
endfunction

augroup splitsize
  autocmd!
  autocmd BufWritePost * call CheckCtagsAge()
augroup END
