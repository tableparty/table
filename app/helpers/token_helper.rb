module TokenHelper
  def options_for_token_size
    Token.size_names.map { |name| [name.capitalize, name] }
  end
end
