def email_field_tag(name, value = nil, options = {})
  text_field_tag(name, value, options.stringify_keys.update("type" => "email"))
end
