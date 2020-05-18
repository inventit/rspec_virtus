require 'rspec/core'
require 'rspec/virtus/matcher'
require 'rspec/virtus/version'

module RSpec
  module Virtus
    # rubocop:disable Style/PredicateName
    def have_attribute(attribute_name)
      Matcher.new(attribute_name)
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Virtus
end
