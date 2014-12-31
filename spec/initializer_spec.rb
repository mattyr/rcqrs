require 'spec_helper'

module Rcqrs
  class Car
    extend Initializer

    attr_reader :manufacturer, :model, :bhp, :ps

    initializer :manufacturer, :model, :bhp do
      @ps = bhp.to_f / 2
    end
  end

  class Bike
    extend Initializer
    initializer :manufacturer, :attr_reader => true
  end

  RSpec.describe Car do
    context "when creating with positional arguments" do
      before(:each) do
        @car = Car.new('Ford', 'Focus', 115)
      end

      it "should set the manufacturer" do
        expect(@car.manufacturer).to eq('Ford')
      end

      it "should set the manufacturer" do
        expect(@car.model).to eq('Focus')
      end

      it "should set the bhp and ps from power" do
        expect(@car.bhp).to eq(115)
        expect(@car.ps).to eq(57.5)
      end
    end

    context "when creating with named arguments" do
      before(:each) do
        @car = Car.new(:model => 'Focus', :manufacturer => 'Ford')
      end

      it "should set the manufacturer" do
        expect(@car.manufacturer).to eq('Ford')
      end

      it "should set the manufacturer" do
        expect(@car.model).to eq('Focus')
      end
    end

    context "when creating with arguments hash" do
      before(:each) do
        arguments = { :manufacturer => 'Ford', :model => 'Focus' }
        @car = Car.new(arguments)
      end

      it "should set the manufacturer" do
        expect(@car.manufacturer).to eq('Ford')
      end

      it "should set the manufacturer" do
        expect(@car.model).to eq('Focus')
      end
    end

    context "when creating with invalid parameter" do
      it "should raise an exception" do
        expect(proc { Car.new(:invalid => 'x') }).to raise_error(ArgumentError)
      end
    end

    context "when getting the attributes" do
      before(:each) do
        @car = Car.new(:manufacturer => 'Ford', :model => 'Focus', :bhp => 115)
      end

      it "should return hash of all attributes" do
        expect(@car.attributes).to eq({ :manufacturer => 'Ford', :model => 'Focus', :bhp => 115 })
      end

      it "should allow creation of new object from existing object's attributes" do
        cloned = Car.new(@car.attributes)
        expect(cloned.manufacturer).to eq('Ford')
      end
    end

    context "when defining attrs automatically" do
      before (:each) do
        @bike = Bike.new('Planet X')
      end

      it "should have attr_reader defined" do
        expect(@bike.manufacturer).to eq('Planet X')
      end
    end

    context "when initializing from another initialized object with attributes" do
      before (:each) do
        @bike = Bike.new('Planet X')
        @car = Car.new(@bike)
      end

      it "should set manufacturer" do
        expect(@car.manufacturer).to eq(@bike.manufacturer)
      end
    end
  end
end
