AttributeNormalizer.configure do |config|
  config.normalizers[:reject_blank] = lambda do |array, options|
    array = Array.wrap(array)
    array.compact!
    array.reject(&:blank?)
  end
end
