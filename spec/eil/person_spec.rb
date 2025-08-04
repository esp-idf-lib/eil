# frozen_string_literal: true

require "spec_helper"

RSpec.describe EIL::Person do
  let(:name) { "trombik" }
  let(:person) { described_class.new(name) }

  before do
    EIL.root = root
  end

  describe ".new" do
    it "finds trombik" do
      expect(person).to be_a described_class
    end

    context "when person not in the file is given" do
      it "raises ArgumentError" do
        expect { described_class.new("foobarbuz") }.to raise_error ArgumentError
      end
    end
  end

  describe "#full_name" do
    it "returns the full name" do
      expect(person.full_name).to eq "Tomoyuki Sakurai"
    end
  end

  describe "#gh_id" do
    it "returns GH ID" do
      expect(person.gh_id).to eq name
    end
  end

  describe "#email" do
    it "returns email" do
      expect(person.email).to eq "y@trombik.org"
    end
  end

  describe "#url" do
    it "returns nil" do
      expect(person.url).to be_nil
    end
  end

  describe "#contributed_components" do
    it "returns esp_idf_lib_helpers only" do
      expect(person.contributed_components.map(&:name)).to eq ["esp_idf_lib_helpers"]
    end
  end

  describe ".all" do
    it "returns an Array of described_class" do
      expect(described_class.all).to all(be_a described_class)
    end
  end
end
