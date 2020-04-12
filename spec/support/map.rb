def have_map_with_data(map, attribute, value)
  have_css(
    ".current-map[data-map-id='#{map.id}'][data-#{attribute}='#{value}']"
  )
end

def have_token_with_data(token, attribute, value)
  have_css(
    ".token[data-token-id='#{token.id}'][data-#{attribute}='#{value}']"
  )
end

def have_token(token)
  have_css(".token[data-token-id='#{token.id}']")
end
