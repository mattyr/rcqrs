describe Rcqrs::Projectors::Registry do
  it "should automatically register classes including projector model" do
    expect(Rcqrs::Projectors::Registry.projectors.first).to be_instance_of(Projectors::ReportingProjector)
  end
end
