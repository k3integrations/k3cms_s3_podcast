AttributeNormalizer.configure do |config|
  config.normalizers[:reject_blank] = lambda do |array, options|
    array.reject(&:blank?)
  end
end
