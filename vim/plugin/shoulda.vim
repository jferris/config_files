function! s:ShouldaBufSyntax()
  if (!exists("g:rails_syntax") || g:rails_syntax)
    let t = RailsFileType()
    if &syntax == 'ruby'
      if t =~ '^test'
        syn keyword rubyRailsTestMethod assert_bad_value   assert_contains   assert_did_not_send_email   assert_does_not_contain   assert_good_value   assert_same_elements   assert_save   assert_sent_email   assert_valid   pretty_error_messages   report!
      endif
      if t =~ '^test-unit'
        syn keyword rubyRailsTestMethod should_allow_values_for   should_belong_to   should_ensure_length_at_least   should_ensure_length_in_range   should_ensure_length_is   should_ensure_value_in_range   should_have_and_belong_to_many   should_have_class_methods   should_have_db_column   should_have_db_columns   should_have_index   should_have_indices   should_have_instance_methods   should_have_many   should_have_named_scope   should_have_one   should_have_readonly_attributes   should_not_allow_values_for   should_only_allow_numeric_values_for   should_protect_attributes   should_require_acceptance_of   should_require_attributes   should_require_unique_attributes  
      elseif t=~ '^test-functional'
        syn keyword rubyRailsTestMethod should_assign_to   should_be_restful   should_not_assign_to   should_not_set_the_flash   should_redirect_to   should_render_a_form   should_render_template   should_respond_with   should_set_the_flash_to  assert_xml_response   request_xml  should_respond_with_xml   should_respond_with_xml_for
      endif
    endif
  endif
endfunction

augroup railsPluginDetect
  autocmd Syntax ruby if exists("b:rails_root") | call s:ShouldaBufSyntax() | endif
augroup END

function! ShouldaReplaceEach(macro, template)
  let lineno = search(a:macro, "wnc")
  while lineno > 0
    let line = getline(lineno)
    while match(line, ",\\s*$") != -1
      execute lineno . "," . (lineno + 1) . "join"
      let line = getline(lineno)
    endwhile
    let pieces = split(line, "\\s*{\\s*")
    let line = pieces[0]
    if len(pieces) == 1
      let withArg = ""
    else
      let withArg = ".with(" . substitute(pieces[1], "\\s*}\\s*$", "", "") . ")"
    endif
    let attrs = matchlist(line, "^\\(\\s\\+\\)" . a:macro . "(\\?\\([^)]*\\))\\?\\s*$")
    let lead = attrs[1]
    let attrs = split(attrs[2], ",\\s*")
    let opts = []
    while match(attrs[-1], "=>") != -1
      let opts = opts + [attrs[-1]]
      let attrs = attrs[:-2]
    endwhile
    echo opts
    let replace = 1
    for attr in attrs
      if attr != ""
        let result = lead . substitute(a:template, "%s", attr, "")
        let result = substitute(result, ") }", ")" . withArg . " }", "")
        if replace
          let replace = 0
          call setline(lineno, result)
        else
          call append(lineno, result)
        endif
      endif
    endfor
    let lineno = search(a:macro, "wnc")
  endwhile
endfunction

function! AppendAfterPrevious(pattern, startline, content)
  let lineno = a:startline
  while lineno > 0
    let line = getline(lineno)
    if match(line, a:pattern) != -1
      call append(lineno, a:content)
      let lineno = 0
    else
      let lineno = lineno - 1
    endif
  endwhile
endfunction

function! ShouldaReplaceShouldChange()
  let lineno = search("should_change", "wnc")
  while lineno > 0
    let line = getline(lineno)
    let parts = matchlist(line, "\\(\\s\\+\\)should_change(\\([^,]\\+\\), :by => \\(\\d\\+\\)) { \\(.*\\) }")
    let lead = parts[1]
    let desc = substitute(parts[2], "['\"]", "", "g")
    let delta = parts[3]
    let rubyExpr = parts[4]
    let ivar = "@" . tolower(substitute(desc, "\\W", "_", "g"))
    call setline(lineno, lead . "it \"should change " . desc . " by " . delta . "\" do")
    call append(lineno, lead . "end")
    call append(lineno, lead . "  (" . rubyExpr . ").should == " . ivar . " + " . delta)
    call AppendAfterPrevious("describe", lineno, lead . "before { " . ivar . " = " . rubyExpr . "}")
    let lineno = search("should_change", "wnc")
  endwhile

  let lineno = search("should_not_change", "wnc")
  while lineno > 0
    let line = getline(lineno)
    let parts = matchlist(line, "\\(\\s\\+\\)should_not_change(\\([^)]\\+\\)) { \\(.*\\) }")
    let lead = parts[1]
    let desc = substitute(parts[2], "['\"]", "", "g")
    let rubyExpr = parts[3]
    let ivar = "@" . tolower(substitute(desc, "\\W", "_", "g"))
    call setline(lineno, lead . "it \"should not change " . desc . "\" do")
    call append(lineno, lead . "end")
    call append(lineno, lead . "  (" . rubyExpr . ").should == " . ivar)
    call AppendAfterPrevious("describe", lineno, lead . "before { " . ivar . " = " . rubyExpr . "}")
    let lineno = search("should_not_change", "wnc")
  endwhile
endfunction

function! ToRSpec()
  " Remove trailing space
  silent! %s/\s\+$//g

  " Context
  silent! %s/^\(\s\+\)context /\1describe /
  silent! %s/^\(\s\+\)setup /\1before /
  silent! %s/^\(\s\+\)teardown /\1after /
  silent! %s/^\(\s\+\)should \"/\1it \"should /
  silent! %s/^\(\s\+\)def setup\s*$/\1before do/
  silent! %s/^\(\s\+\)def teardown\s*$/\1after do/

  " Macros
  silent! %s/should_set_the_flash_to \(.*\)/it { should set_the_flash.to(\1) }/
  silent! %s/should_set_the_flash_to(\(.*\))/it { should set_the_flash.to(\1) }/
  silent! %s/should_not_set_the_flash/it { should_not set_the_flash }/
  silent! %s/should_respond_with \(.*\)/it { should respond_with(\1) }/
  silent! %s/should_render_template \(.*\)/it { should render_template(\1) }/
  silent! %s/should_route \([:a-z]\+\), \([^,]\+\), \(.\+\)/it { should route(\1, \2).to(\3) }/
  silent! %s/should_deny_access :flash => \(.*\)/it { should deny_access.flash(\1) }/
  silent! %s/\(\s*\)should_allow_values_for\s*\([^,]\+\), \([^,]*,.*\)/\1[\3].each do |value|\1  it { should allow_value(value).for(\2) }\1end/
  silent! %s/should_ensure_length_at_least\s*\([^,]\+\),\s*\(.\+\)/it { should ensure_length_of(\1).is_at_least(\2) }/
  silent! %s/should_allow_values_for\s*\([^,]\+\), \(.*\)/it { should allow_value(\2).for(\1) }/
  silent! %s/\(\s*\)should_not_allow_values_for\s*\([^,]\+\),\s*\([^,]*,.*\),\s*:message\s*=>\s*\(.\+\)/\1[\3].each do |value|\1  it { should_not allow_value(value).for(\2).with_message(\4) }\1end/
  silent! %s/\(\s*\)should_not_allow_values_for\s*\([^,]\+\), \([^,]*,.*\)/\1[\3].each do |value|\1  it { should_not allow_value(value).for(\2) }\1end/
  silent! %s/should_not_allow_values_for\s*\([^,]\+\), \(.*\)/it { should_not allow_value(\2).for(\1) }/
  silent! %s/^\(\s*\)should_redirect_to(['"]\(.*\)['"]) { \(.*\) }/\1it "should redirect to \2" do\1  should redirect_to(\3)\1end/
  call ShouldaReplaceShouldChange()
  call ShouldaReplaceEach("should_filter_params", "it { should filter_param(%s) }")
  call ShouldaReplaceEach("should_assign_to", "it { should assign_to(%s) }")
  call ShouldaReplaceEach("should_validate_presence_of", "it { should validate_presence_of(%s) }")
  call ShouldaReplaceEach("should_validate_uniqueness_of", "it { should validate_uniqueness_of(%s) }")
  call ShouldaReplaceEach("should_not_allow_mass_assignment_of", "it { should_not allow_mass_assignment_of(%s) }")
  call ShouldaReplaceEach("should_allow_mass_assignment_of", "it { should allow_mass_assignment_of(%s) }")
  call ShouldaReplaceEach("should_have_many", "it { should have_many(%s) }")
  call ShouldaReplaceEach("should_belong_to", "it { should belong_to(%s) }")
  call ShouldaReplaceEach("should_have_one", "it { should have_one(%s) }")

  " Assertions
  silent! %s/assert ! \?\(.*\)\.\(\w\+\)?$/\1.should_not be_\2/
  silent! %s/assert \(.*\)\.\(\w\+\)?$/\1.should be_\2/
  silent! %s/assert \(.*\)\.include?(\([^)]*\))/\1.should include(\2)/
  silent! %s/assert ! \?\(.*\)/(\1).should_not be/
  silent! %s/assert \(.*\)/(\1).should be/
  silent! %s/assert_nil \(.*\)/\1.should be_nil/
  silent! %s/\(\s*\)assert_not_nil \(.*\) = \(.*\)/\1\2 = \3\1\2.should_not be_nil/
  silent! %s/assert_not_nil \(.*\)/\1.should_not be_nil/
  silent! %s/assert_equal \([^,]*\), \([^,]*\)$/\2.should == \1/
  silent! %s/assert_not_equal \([^,]*\), \([^,]*\)$/\2.should_not == \1/
  silent! %s/assert_match \([^,]*\), \([^,]*\)/\2.should =\~ \1/
  silent! %s/assert_kind_of \([^,]*\), \([^,]*\)/\2.should be_kind_of(\1)/
  silent! %s/assert_received(\([^,]\+\),\s*\([^)]\+\))\s*{\s*[^ ]\+ [^\.]\+.\(.*\)\s*}/\1.should have_received(\2).\3/
  silent! %s/assert_contains \([^,]*\), \([^,]*\)$/\1.should =\~ \2/

  " Top-level classes
  silent! %s/class \(.\+\)Test < .*::TestCase/describe \1 do/

  " Highlight unreplaced macros/assertions
  highlight tunit ctermbg=red guibg=red
  call matchadd("tunit", "assert\\w*")
  call matchadd("tunit", "should_\\(not \\|behave_like\\)\\@!\\w*")
  call search("assert", "wc")
  call search("should_", "wc")
endfunction

command! ToRSpec call ToRSpec()

function! ToRSpecContext()
  " Remove trailing space
  silent! %s/\s\+$//g

  " Context
  silent! %s/^\(\s\+\)context /\1describe /
  silent! %s/^\(\s\+\)setup /\1before /
  silent! %s/^\(\s\+\)teardown /\1after /
  silent! %s/^\(\s\+\)should \"/\1it \"should /
  silent! %s/^\(\s\+\)def setup\s*$/\1before do/
  silent! %s/^\(\s\+\)def teardown\s*$/\1after do/

  " Top-level classes
  silent! %s/class \(.\+\)Test < .*::TestCase/describe \1 do/

  " Highlight unreplaced macros/assertions
  highlight tunit ctermbg=red guibg=red
  call matchadd("tunit", "should_\\(not \\|behave_like\\)\\@!\\w*")
  call search("should_", "wc")
endfunction

command! ToRSpecContext call ToRSpecContext()
