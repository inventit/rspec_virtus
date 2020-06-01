module RSpec
  module Virtus
    class Matcher
      def initialize(attribute_name)
        @attribute_name = attribute_name
      end

      def description
        "have attribute #{@attribute_name}"
      end

      def of_type(type)
        @type = type
        self
      end

      def with_options(options={})
        @options = options.slice(:accessor, :reader, :writer, :relation, :lazy, :strict, :required, :finalize, :nullify_blank)
        self
      end

      def with_default(default_value, evaluate: false)
        @default_value = {value: default_value, evaluate: evaluate}
        self
      end

      def matches?(instance)
        @instance = instance
        @subject = instance.class
        attribute_exists? && type_correct? && default_value_correct? && options_correct?
      end

      def failure_message
        "expected #{@attribute_name} to be defined"
      end

      def failure_message_when_negated
        "expect #{@attribute_name} not to be defined"
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
          @default_value[:evaluate] ? value.call(@instance, attribute) : :proc
        when ::Symbol
          @default_value[:evaluate] && @instance.respond_to?(value, true) ? @instance.__send__(value) : value
        else
          value
        end
      end

      def type_correct?
        if @type.is_a?(::Array)
          attribute_type == @type.class && member_type == @type.first
        elsif @type
          attribute_type == @type
        else
          true
        end
      end

      def default_value_correct?
        return true unless @default_value
        attribute_default_value == @default_value[:value]
      end

      def options_correct?
        @options.nil? || @options.empty? || @options.all? { |name, value| attribute.options[name] == value }
      end
    end
  end
end
