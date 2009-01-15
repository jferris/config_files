function! Git(args)
  if a:args == 'add'
    write
    execute "silent !git add %"
  elseif a:args == 'next-unmerged'
    let unmerged = system("git-unmerged-next")
    if unmerged == ''
      echo "No unmerged files remaining"
    else
      execute "edit " . unmerged
    endif
  elseif a:args == 'resolve'
    call Git('add')
    call Git('next-unmerged')
  else
    echoe "No such git command: " . a:args
  endif
endfunction

command! -nargs=* -complete=file Git call Git(<q-args>)
