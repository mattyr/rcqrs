require 'spec_helper'

describe Rcqrs::Projectors::Registry do
  it "should automatically register classes including projector model" do
    expect(Rcqrs::Projectors::Registry.projectors.first).to be_instance_of(Projectors::ReportingProjector)
  end

  it "should keep classes unique by name" do
    Rcqrs::Projectors::Registry.instance.projector_classes.clear

    class FakeProjector
    end

    Rcqrs::Projectors::Registry.register(FakeProjector)

    # we unload and redefine, making class equality check fail
    Object.send(:remove_const, :FakeProjector)

    class FakeProjector
    end

    expect(Rcqrs::Projectors::Registry.instance.projector_classes.first).to_not eq(FakeProjector)

    Rcqrs::Projectors::Registry.register(FakeProjector)

    expect(Rcqrs::Projectors::Registry.instance.projector_classes.length).to eq(1)
  end
end
