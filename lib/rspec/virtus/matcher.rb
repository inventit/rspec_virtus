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
        @type.nil? || correct_type?(@type, attribute)
      end

      def correct_type?(expected, actual)
        case expected
        when ::Array, ::Set
          actual.is_a?(::Virtus::Attribute::Collection) \
            && actual.primitive == expected.class \
            && correct_type?(expected.first, actual.member_type)
        when ::Hash
          key_type, value_type = expected.first
          actual.is_a?(::Virtus::Attribute::Hash) \
            && actual.primitive == Hash \
            && correct_type?(key_type, actual.key_type) \
            && correct_type?(value_type, actual.value_type)
        else
          normalized = \
            (expected.is_a?(String) || expected.is_a?(Symbol)) && Object.const_get(expected.to_s) || expected
          type_definition = ::Virtus::TypeDefinition.new(normalized)
          detected_class = \
            ::Virtus::Attribute::Builder.determine_type(type_definition.primitive, ::Virtus::Attribute)
          detected_type = detected_class.build_type(type_definition)
          actual.instance_of?(normalized) \
            || normalized == actual.primitive \
            || actual.instance_of?(detected_class) && actual.type == detected_type(expected)
        end
      end

      def detected_type(klass)
        type_definition = ::Virtus::TypeDefinition.new(klass)
        ::Virtus::Attribute::Builder.determine_type(type_definition.primitive, ::Virtus::Attribute) \
          .build_type(type_definition)
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
