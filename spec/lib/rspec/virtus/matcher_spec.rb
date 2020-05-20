require 'spec_helper'
require 'virtus'

describe RSpec::Virtus::Matcher do
  let(:instance) { described_class.new(attribute_name) }
  let(:attribute_name) { :the_attribute }

  class DummyVirtus
    include Virtus.model

    attribute :the_attribute, String
    attribute :the_array_attribute, Array[String]
    attribute :the_integer_attribute_with_default, Integer, default: 5
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
  end

  describe '#of_type' do
    subject { instance.of_type(String) }

    it 'returns itsself so it can be chained' do
      expect(subject).to eql(instance)
    end

    context 'singular values' do
      it 'adds an option to allow the type to be checked' do
        options_type = subject.instance_variable_get(:@options)[:type]
        expect(options_type).to eql(String)
      end
    end

    context 'arrays of values' do
      subject { instance.of_type(Array[String]) }

      it 'adds an option to allow the type to be checked' do
        options_type = subject.instance_variable_get(:@options)[:type].class
        expect(options_type).to eql(Array)
      end

      it 'adds an option to allow the member_type to be checked' do
        member_options_type = subject.instance_variable_get(:@options)[:type].first
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
      options_default_value = subject.instance_variable_get(:@options)[:default_value][:value]
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
