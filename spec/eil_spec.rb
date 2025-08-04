# frozen_string_literal: true

RSpec.describe EIL do
  it "has a version number" do
    expect(EIL::VERSION).not_to be_nil
  end

  describe ".root" do
    it "sets repository root" do
      path = Pathname.new(".")
      described_class.root = path
      expect(described_class.root).to eq path
    end
  end
end
