require 'spec_helper'

# convert ActiveModel lint tests to RSpec
shared_examples_for "ActiveModel" do
  require 'minitest/assertions'
  include Minitest::Assertions
  include ActiveModel::Lint::Tests

  attr_accessor :assertions

  def initialize
    @assertions = 0
  end

  # to_s is to support ruby-1.9
  ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
    example m.gsub('_',' ') do
      send m
    end
  end

  def model
    subject
  end
end

module Commands
  describe CreateCompanyCommand do
    before(:each) do
      @command = Commands::CreateCompanyCommand.new(:name => 'ACME corp')
    end

    subject { @command }
    it_should_behave_like "ActiveModel"

    specify { @command.valid? }

    context "invalid command" do
      before(:each) do
        @command = Commands::CreateCompanyCommand.new
        @command.valid?
      end

      specify { @command.invalid? }
      specify { expect(@command.errors[:name]).to eq(["can't be blank"]) }
    end
  end
end
