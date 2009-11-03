" Load .vimrc from the current directory if there is one
function! LoadCwdConfig()
  let rcfile = join([getcwd(), ".vimrc"], "/")
  if filereadable(rcfile)
    execute "source " . rcfile
  end
endfunction

autocmd BufRead * call LoadCwdConfig()
