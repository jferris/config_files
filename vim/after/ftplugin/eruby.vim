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

" general ruby snippets
Snippet each each do |``ERubyIterVar()``| -%><CR><{}><CR><% end -%>
Snippet map map do |``ERubyIterVar()``|<CR><{}><CR>end
" Snippet each <% <{collection}>.each do |<{member}>| -%><CR><{}><CR><% end %>
Snippet h <%=h <{}> %>
Snippet = <%= <{}> %>
Snippet rendp <%= render :partial => '<{}>' %>
Snippet rendc <%= render :partial => @<{}> %>
Snippet rendo <%= render :partial => @<{}> %>
Snippet lt <%= link_to '<{caption}>', <{}> %>
