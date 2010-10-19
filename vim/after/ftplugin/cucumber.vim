" Webrat steps
Snippet press When I press "<{}>"
Snippet follow When I follow "<{}>"
Snippet fillin When I fill in "<{field}>" with "<{}>"
Snippet select When I select "<{value}>" from "<{}>"
Snippet check When I check "<{}>"
Snippet uncheck When I uncheck "<{}>"
Snippet choose When I choose "<{}>"
Snippet see Then I should see "<{}>"
Snippet notsee Then I should not see "<{}>"
Snippet visit When I visit <{}>

" Factory steps
Snippet exist Given a <{factory}> exists with a <{attribute}> of "<{}>"

function! AlignAsciiTable()
  let startline = line(".")
  while match(getline(startline), "|") != -1
    let startline = startline - 1
  endwhile
  let startline = startline + 1

  let endline = startline
  while match(getline(endline), "|") != -1
    let endline = endline + 1
  endwhile
  let endline = endline - 1

  if startline >= endline
    return
  endif

  exec startline . "," . endline . "!align_ascii_table"
endfunction

nmap <buffer> <C-A> :call AlignAsciiTable()<CR>

vmap <buffer> <C-A> !align_ascii_table<CR>
