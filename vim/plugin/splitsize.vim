if has("gui_running")

  set equalalways

  function! IsWinSplit()
    for item in tabpagebuflist()
      let l:bufwidth = winwidth(bufwinnr(item))
      if &columns != l:bufwidth && g:halfsize != l:bufwidth
        return 1
      endif
    endfor
    return 0
  endfunction

  function! SetWidthForSplit()
    if IsWinSplit()
      let &columns = g:fullsize
    else
      let &columns = g:halfsize
    endif
  endfunction

  augroup splitsize
    autocmd!
    autocmd WinEnter * call SetWidthForSplit()
  augroup END

endif
