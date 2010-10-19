function! ERubyIterVar()
  let line = getline('.')
  let col = col('.')
  let collection = line[0 : col]
  " remove .each or .collect
  let collection = substitute(collection,"\\.[^.]*$","","")
  " remove eruby escapes
  let collection = substitute(collection,"^<%","","")
  " remove leading space
  let collection = substitute(collection,"^\\s\\+","","")
  " remove chains like post.users
  let collection = substitute(collection,"^.*\\.","","")
  " remove instance variable punctuatoin
  let collection = substitute(collection,"^@","","")
  " singularize
  return rails#singularize(collection)
endfunction

" general erb snippets
Snippet each each do |``ERubyIterVar()``| -%><CR><{}><CR><% end -%>
Snippet map map do |``ERubyIterVar()``|<CR><{}><CR>end
Snippet = <%= <{}> %>
Snippet if <% if <{}> -%><CR><CR><% end -%>
Snippet unless <% unless <{}> -%><CR><CR><% end -%>

" rails snippets
Snippet h <%=h <{}> %>
Snippet rp <%= render :partial => '<{}>' %>
Snippet lt <%= link_to <{caption}>, <{}> %>
Snippet ctf <% content_tag_for :<{tag}>, <{object}> do -%><CR><{}><CR><% end -%>
Snippet cf <% content_for :<{capture}> do -%><CR><{}><CR><% end -%>
Snippet cfj <% content_for :javascript do -%><CR><script type="text/javascript"><CR><{}><CR></script><CR><% end -%>
