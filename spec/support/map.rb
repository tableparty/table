def have_map_with_data(map, attribute, value)
  have_css(
    ".current-map[data-map-id='#{map.id}'][data-#{attribute}='#{value}']"
  )
end

RSpec::Matchers.define :have_token do |token|
  match do |container|
    container.has_css?(".token[data-token-id='#{token.to_param}']")
  end
end

RSpec::Matchers.define :have_token_with_data do |token, key, value|
  match do |container|
    container.has_css?(
      ".token[data-token-id='#{token.to_param}'][data-#{key}='#{value}']"
    )
  end

  failure_message do |container|
    token_element = container.find(".token[data-token-id='#{token.to_param}']")
    actual_value = token_element.native.attribute("data-#{key}")
    <<~MSG
      expected token to have attribute '#{key}' with value '#{value}' but
      instead had value '#{actual_value}'
    MSG
  end
end
