class UriValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    _options = options.reverse_merge(
      :message => "is invalid",
      :format => URI::regexp(%w(http https))
    )
    options = _options
    
    unless value =~ options[:format]
      object.errors.add(attribute, options[:message])
    end
  end
end


