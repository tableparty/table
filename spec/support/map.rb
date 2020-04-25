def have_map_with_data(map, attribute, value)
  have_css(
    ".current-map[data-map-id='#{map.id}'][data-#{attribute}='#{value}']"
  )
end

RSpec::Matchers.define :have_token do |token|
  match do |container|
    container.has_css?(".token[data-token-id='#{token.to_param}']", count: 1)
  end
end

RSpec::Matchers.define :have_token_with_identifier do |token, identifier|
  match do |container|
    container.has_css?(
      ".token[data-token-id='#{token.to_param}'] .token__identifier",
      text: identifier
    )
  end

  failure_message do |container|
    if container.has_css?(".token[data-token-id='#{token.to_param}']")
      if container.has_css?(
        ".token[data-token-id='#{token.to_param}'] .token__identifier"
      )
        identifier_element = container.find(
          ".token[data-token-id='#{token.to_param}'] .token__identifier"
        )
        <<~MSG
          expected token #{token.to_param} to have identifier '#{identifier}',
          but instead had value '#{identifier_element.text}'
        MSG
      else
        <<~MSG
          expected token #{token.to_param} with identifier #{identifier}.
          Token was found, but it had no identifier.
        MSG
      end
    else
      <<~MSG
        expected token #{token.to_param} not found.
      MSG
    end
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
