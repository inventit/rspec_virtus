module RSpec
  module Virtus
    class Matcher
      def initialize(attribute_name)
        @attribute_name = attribute_name
        @options = {}
      end

      def description
        msg = "have attribute #{@attribute_name}"
        msg << ", #{normalize_type}" if @options[:type]
        msg << ", default: #{@options[:default_value]}" if @options[:default_value]
        msg << ", required: #{@options[:required]}" unless @options[:required].nil?
        msg
      end

      def of_type(type)
        @options[:type] = type
        self
      end

      def with_default(default_value, evaluate: false)
        @options[:default_value] = {value: default_value, evaluate: evaluate}
        self
      end

      def with_required(value)
        @options[:required] = value
        self
      end

      def matches?(instance)
        @instance = instance
        @subject = instance.class
        @match_attribute_exists = attribute_exists?
        return false unless @match_attribute_exists
        @match_type_correct = type_correct?
        @match_default_value_correct = default_value_correct?
        @match_required_correct = required?
        @match_attribute_exists && @match_type_correct && @match_default_value_correct && @match_required_correct
      end

      def failure_message
        msg = ["expected #{@attribute_name} to be defined"]
        msg << "have type #{normalize_type}" if @options.key?(:type) && !@match_type_correct
        msg << 'have correct default value'  if @options.key?(:default_value) && !@match_default_value_correct
        msg << 'have correct required flag'  if @options.key?(:required) && !@match_required_correct
        msg.join(' and ')
      end

      def failure_message_when_negated
        msg = ["expect #{@attribute_name} not to be defined"]
        msg << "not have type #{normalize_type}" if @options.key?(:type)
        msg << 'not have correct default value'  if @options.key?(:default_value)
        msg << 'not have correct required flag'  if @options.key?(:required)
        msg.join(' and ')
      end

      private

      def attribute
        @subject.attribute_set[@attribute_name]
      end

      def member_type
        attribute.member_type.primitive
      end

      def attribute_type
        attribute.primitive
      end

      def attribute_exists?
        !attribute.nil?
      end

      def attribute_default_value
        value = attribute.default_value.value

        case value
        when ::Proc
          @options[:default_value][:evaluate] ? value.call(@instance, attribute) : :proc
        when ::Symbol
          @options[:default_value][:evaluate] && @instance.respond_to?(value, true) ? @instance.__send__(value) : value
        else
          value
        end
      end

      def type_correct?
        if @options[:type].is_a?(::Array)
          attribute_type == @options[:type].class && member_type == @options[:type].first
        elsif @options[:type]
          attribute_type == @options[:type]
        else
          true
        end
      end

      def default_value_correct?
        return true unless @options[:default_value]
        attribute_default_value == @options[:default_value][:value]
      end

      def required?
        return true if @options[:required].nil?
        attribute.required? == @options[:required]
      end

      def normalize_type
        if @options[:type].is_a?(::Array)
          "#{@options[:type].class}[#{@options[:type].first}]"
        else
          @options[:type]
        end
      end
    end
  end
end
