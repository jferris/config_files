function! ValuesComplete(findstart, base)
  let lineUpToCursor = strpart(getline('.'), 0, col(".") - 1)
  let quoteIndex = matchend(lineUpToCursor, '.*"')

  if a:findstart
    return quoteIndex
  endif

  let values = []

  let lineNum = 1
  while lineNum <= line("$")
    let line = getline(lineNum)
    let value = matchstr(line, '"[^"]\+"')
    let values += [substitute(value, '"', '', "g")]
    let lineNum += 1
  endwhile
  call filter(values,'strpart(v:val,0,strlen(a:base)) ==# a:base')
  return values
endfunction

