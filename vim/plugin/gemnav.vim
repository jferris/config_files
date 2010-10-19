" gemnav.vim - Navigate around Rubygems projects
" Author:       Joe Ferris

" Assumes the following project structure:
" /PROJECT.gemspec
" /lib/PROJECT.rb
" /lib/PROJECT/**/*.rb
" /spec/spec_helper.rb
" /spec/PROJECT/**/*_spec.rb
" /features/support/env.rb
" /features/**/*.feature
" /features/step_definitions/**/*_steps.rb

function! RGSpec()
  let dir = expand("%:p")
  let gemspec = ""
  while gemspec == "" && dir != "/"
    let dir = fnamemodify(dir, ":h")
    let gemspec = glob(dir . "/*.gemspec")
  endwhile
  return gemspec
endfunction

function! RGSub(string)
  return substitute(a:string, "{name}", b:gemname, "g")
endfunction

function! RGGlob(name, partial)
  let opts = b:gemnav[a:name]
  let prefix = b:gemroot . "/" . RGSub(opts["prefix"]) . "/"
  let suffix = substitute(opts["glob"], "\*", "", "g")
  let pattern = "**/" . a:partial . opts["glob"]
  let paths = split(glob(prefix . pattern), "\n")
  let results = []
  for path in paths
    let result = strpart(path, len(prefix))
    let result = strpart(result, 0, len(result) - len(suffix))
    let results += [result]
  endfor
  return join(results, "\n")
endfunction

function! RGNav(name, editCommand, partial)
  let opts = b:gemnav[a:name]
  if a:partial == ""
    let pattern = RGSub(opts['default'])
  else
    let pattern = RGSub(opts['prefix']) . "/" . "**/" . a:partial . opts['glob']
  endif
  let matches = split(glob(b:gemroot . "/" . pattern), "\n")
  if len(matches) == 1
    execute a:editCommand . " " . matches[0]
  elseif len(matches) == 0
    throw "No such file: " . pattern
  else
    throw "Multiple files match: " . pattern
  endif
endfunction

function! RGComplete(argLead, cmdLine, cursorPos)
  let commandName = substitute(a:cmdLine, " .*", "", "")
  let name = b:gemcommands[commandName]
  return RGGlob(name, a:argLead)
endfunction

function! RGCreateNav(commandPrefix, name, editCommand, key)
  let commandName = "RG" . a:commandPrefix . a:name
  let b:gemcommands[commandName] = a:name
  execute "command! -nargs=? -complete=custom,RGComplete " . commandName . " call RGNav('" . a:name . "', '" . a:editCommand . "', <q-args>)"
  execute "nmap <buffer> <Leader>" . a:key . " :" . commandName . " "
endfunction

function! RGCreateNavSet(name, prefix, glob, default, key)
  let b:gemnav[a:name] = { 'prefix' : a:prefix, 'glob' : a:glob, 'default' : a:default }
  call RGCreateNav("", a:name, "edit", a:key)
  call RGCreateNav("S", a:name, "split", "s" . a:key)
  call RGCreateNav("T", a:name, "tabe", "t" . a:key)
  call RGCreateNav("V", a:name, "vsplit", "v" . a:key)
endfunction

function! RGDetect()
  let gemspec = RGSpec()
  if gemspec != ""
    let b:gemspec = gemspec
    let b:gemname = fnamemodify(b:gemspec, ":t:r")
    let b:gemroot = fnamemodify(b:gemspec, ":h")
    let b:gemnav = {}
    let b:gemcommands = {}

    call RGCreateNavSet("lib", "lib/{name}", "*.rb", "lib/{name}.rb", "l")
    call RGCreateNavSet("test", "spec/{name}", "*_spec.rb", "spec/spec_helper.rb", "u")
    call RGCreateNavSet("feature", "features", "*.feature", "features/support/env.rb", "i")
    call RGCreateNavSet("step", "features/step_definitions", "*_steps.rb", "features/support/env.rb", "p")
  endif
endfunction

augroup rubygems
  au!
  au BufNewFile,BufRead * call RGDetect()
augroup END

