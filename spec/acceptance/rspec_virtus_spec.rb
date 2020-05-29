require 'spec_helper'
require 'virtus'

class DummyPost
  class DummyUser
    include Virtus.model(finalize: false)

    attribute :name, String
    attribute :age, Integer, finalize: true
  end

  include Virtus.model

  attribute :title, String, strict: true, default: 'First Post'
  attribute :body, String, nullify_blank: true, default: ''
  attribute :comments, Array[String]
  attribute :greeting, String, default: 'Hello!'
  attribute :default_lambda, String, default: ->(_, _) { 'Wow!' }
  attribute :customs, String, default: :custom_default_via_method
  attribute :some_required, String, default: 'FooBar', required: true
  attribute :dummy_user, DummyUser, relation: true, lazy: true, default: proc { {} }
  attribute :some_private_reader, String, reader: :private
  attribute :some_private_writer, String, writer: :private

  def custom_default_via_method
    'Foo!'
  end
end

describe DummyPost do
  describe DummyPost::DummyUser do
    it { is_expected.to have_attribute(:name).of_type(String).with_options({ finalize: false }) }
    it { is_expected.to have_attribute(:age).of_type(Integer).with_options({ finalize: true }) }
  end

  it { is_expected.to have_attribute(:title).with_options({strict: true}) }
  it { is_expected.to have_attribute(:body).of_type(String).with_options({ nullify_blank: true }) }
  it { is_expected.to have_attribute(:comments).of_type(Array[String]) }
  it { is_expected.to have_attribute(:greeting).of_type(String).with_default('Hello!') }
  it { is_expected.to have_attribute(:default_lambda).of_type(String).with_default('Wow!', evaluate: true) }
  it { is_expected.to have_attribute(:default_lambda).of_type(String).with_default(:proc) }
  it { is_expected.to have_attribute(:customs).of_type(String).with_default('Foo!', evaluate: true) }
  it { is_expected.to have_attribute(:some_required).of_type(String).with_default('FooBar').with_options({ required: true }) }
  it { is_expected.to have_attribute(:dummy_user).of_type(DummyPost::DummyUser).with_options({ relation: true, lazy: true }).with_default(:proc) }
  it { is_expected.to have_attribute(:some_private_reader).of_type(String).with_options({ reader: :private }) }
  it { is_expected.to have_attribute(:some_private_writer).of_type(String).with_options({ writer: :private }) }
end
