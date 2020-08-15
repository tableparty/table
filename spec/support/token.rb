def token_drawer
  find(".current-map__token-drawer")
end

def open_token_drawer
  find("button[title=Tokens]").click
end

def token_element(token)
  find(".token[data-token-id='#{token.id}']")
end
