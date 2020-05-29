require 'spec_helper'
require 'virtus'

describe RSpec::Virtus::Matcher do
  let(:instance) { described_class.new(attribute_name) }
  let(:attribute_name) { :the_attribute }

  class DummyVirtus
    class DummyUser
      include Virtus.model(finalize: false)

      attribute :the_relation_model_attribute, String
      attribute :the_relation_model_attribute_with_finalize, Integer, finalize: true
    end

    include Virtus.model

    attribute :the_attribute, String
    attribute :the_array_attribute, Array[String]
    attribute :the_integer_attribute_with_default, Integer, default: 5
    attribute :the_relational_attribute, DummyUser, relation: true
    attribute :the_string_attribute_with_lazy, String, lazy: true
    attribute :the_string_attribute_with_strict, String, strict: true, default: 'default value'
    attribute :the_string_attribute_with_nullify_blank, String, nullify_blank: true, default: ''
    attribute :the_string_attribute_with_unfinalize, String, finalize: false
    attribute :the_string_attribute_with_private_reader, String, reader: :private
    attribute :the_string_attribute_with_private_writer, String, writer: :private
  end

  describe '#matches?' do
    let(:actual) { DummyVirtus.new }
    subject { instance.matches?(actual) }

    context 'successful match on attribute name' do
      it { is_expected.to be_truthy }
    end

    context 'successful match on attribute name and type' do
      before do
        instance.of_type(String)
      end

      it { is_expected.to be_truthy }
    end

    context 'successful match on attribute name, type and member_type' do
      let(:attribute_name) { :the_array_attribute }

      before do
        instance.of_type(Array[String])
      end

      it { is_expected.to be_truthy }
    end

    context 'successful match with default value' do
      let(:attribute_name) { :the_integer_attribute_with_default }
      before do
        instance.with_default(5)
      end
      it { is_expected.to be_truthy }
    end

    context 'successful match with type and default value' do
      let(:attribute_name) { :the_integer_attribute_with_default }
      before do
        instance.of_type(Integer).with_default(5)
      end
      it { is_expected.to be_truthy }
    end

    context 'successful match with type and relation' do
      let(:attribute_name) { :the_relational_attribute }
      before do
        instance.of_type(DummyVirtus::DummyUser).with_options(relation: true)
      end
      it { is_expected.to be_truthy }
    end

    context 'successful match with type and lazy' do
      let(:attribute_name) { :the_string_attribute_with_lazy }
      before do
        instance.of_type(String).with_options(lazy: true)
      end
      it { is_expected.to be_truthy }
    end

    context 'successful match with type and strict' do
      let(:attribute_name) { :the_string_attribute_with_strict }
      before do
        instance.of_type(String).with_options(strict: true)
      end
      it { is_expected.to be_truthy }
    end

    context 'successful match with type and nullify_blank' do
      let(:attribute_name) { :the_string_attribute_with_nullify_blank }
      before do
        instance.of_type(String).with_options(nullify_blank: true)
      end
      it { is_expected.to be_truthy }
    end

    context 'successful match with type and finalize' do
      let(:attribute_name) { :the_string_attribute_with_unfinalize }
      before do
        instance.of_type(String).with_options(finalize: false)
      end
      it { is_expected.to be_truthy }
    end

    context 'successful match with type and private_reader' do
      let(:attribute_name) { :the_string_attribute_with_private_reader }
      before do
        instance.of_type(String).with_options(reader: :private)
      end
      it { is_expected.to be_truthy }
    end

    context 'successful match with type and private_writer' do
      let(:attribute_name) { :the_string_attribute_with_private_writer }
      before do
        instance.of_type(String).with_options(writer: :private)
      end
      it { is_expected.to be_truthy }
    end

    context 'unsuccessful match on attribute name' do
      let(:attribute_name) { :something_else }

      it { is_expected.to be_falsey }
    end

    context 'unsuccessful match on attribute name and type' do
      let(:attribute_name) { :something_else }

      before do
        instance.of_type(Integer)
      end

      it { is_expected.to be_falsey }
    end

    context 'unsuccessful match on attribute name, type and member_type' do
      let(:attribute_name) { :the_array_attribute }

      before do
        instance.of_type(Array[Integer])
      end

      it { is_expected.to be_falsey }
    end

    context 'unsuccessful match with default value' do
      let(:attribute_name) { :the_integer_attribute_with_default }
      before do
        instance.with_default(-1)
      end
      it { is_expected.to be_falsey }
    end

    context 'unsuccessful match with type and default value' do
      let(:attribute_name) { :the_integer_attribute_with_default }
      before do
        instance.of_type(Integer).with_default(-5)
      end
      it { is_expected.to be_falsey }
    end

    context 'unsuccessful match with type and relation' do
      let(:attribute_name) { :the_relational_attribute }
      before do
        instance.of_type(DummyVirtus::DummyUser).with_options(relation: false)
      end

      it { is_expected.to be_falsey }
    end

    context 'unsuccessful match with type and lazy' do
      let(:attribute_name) { :the_string_attribute_with_lazy }
      before do
        instance.of_type(DummyVirtus::DummyUser).with_options(lazy: false)
      end

      it { is_expected.to be_falsey }
    end

    context 'unsuccessful match with type and strict' do
      let(:attribute_name) { :the_string_attribute_with_strict }
      before do
        instance.of_type(String).with_options(strict: false)
      end

      it { is_expected.to be_falsey }
    end

    context 'unsuccessful match with type and nullify_blank' do
      let(:attribute_name) { :the_string_attribute_with_nullify_blank }
      before do
        instance.of_type(String).with_options(nullify_blank: false)
      end

      it { is_expected.to be_falsey }
    end

    context 'unsuccessful match with type and finalize' do
      let(:attribute_name) { :the_string_attribute_with_unfinalize }
      before do
        instance.of_type(String).with_options(finalize: true)
      end

      it { is_expected.to be_falsey }
    end

    context 'unsuccessful match with type and private_reader' do
      let(:attribute_name) { :the_string_attribute_with_private_reader }
      before do
        instance.of_type(String).with_options(reader: :public)
      end

      it { is_expected.to be_falsey }
    end

    context 'unsuccessful match with type and private_writer' do
      let(:attribute_name) { :the_string_attribute_with_private_writer }
      before do
        instance.of_type(String).with_options(writer: :public)
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#of_type' do
    subject { instance.of_type(String) }

    it 'returns itsself so it can be chained' do
      expect(subject).to eql(instance)
    end

    context 'singular values' do
      it 'adds an option to allow the type to be checked' do
        options_type = subject.instance_variable_get(:@type)
        expect(options_type).to eql(String)
      end
    end

    context 'arrays of values' do
      subject { instance.of_type(Array[String]) }

      it 'adds an option to allow the type to be checked' do
        options_type = subject.instance_variable_get(:@type).class
        expect(options_type).to eql(Array)
      end

      it 'adds an option to allow the member_type to be checked' do
        member_options_type = subject.instance_variable_get(:@type).first
        expect(member_options_type).to eql(String)
      end
    end
  end

  describe '#with_default' do
    subject { instance.with_default('My Default') }

    it 'returns itsself so it can be chained' do
      expect(subject).to eql(instance)
    end

    it 'adds an option to allow the default value to be checked' do
      options_default_value = subject.instance_variable_get(:@default_value)[:value]
      expect(options_default_value).to eql('My Default')
    end
  end

  describe '#description' do
    subject { instance.description }

    it 'tells you which attribute we are testing' do
      expect(subject).to include(attribute_name.to_s)
    end
  end

  describe '#failure_message' do
    subject { instance.failure_message }

    it 'tells you which attribute failed' do
      expect(subject).to include(attribute_name.to_s)
    end
  end

  describe '#failure_message_when_negated' do
    subject { instance.failure_message_when_negated }

    it 'tells you which attribute failed' do
      expect(subject).to include(attribute_name.to_s)
    end
  end
end
