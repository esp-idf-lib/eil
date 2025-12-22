# frozen_string_literal: true

require "spec_helper"

RSpec.describe EIL::Component do
  let(:c) { described_class.new(name) }
  let(:name) { "aht" }
  let(:org) { "esp-idf-lib" }

  before do
    EIL.root = root
  end

  describe ".git_submodule" do
    it "returns String of the output" do
      expect(described_class.git_submodule).to be_a String
    end

    it "caches the output of git submodule" do
      described_class.git_submodule
      expect(described_class.instance_variable_get(:@git_submodule_result)).not_to be_nil
    end
  end

  describe ".git_submodule_names" do
    it "returns Array of component names" do
      expect(described_class.git_submodule_names).to eq %w[aht esp_idf_lib_helpers]
    end
  end

  describe ".all" do
    it "returns array of components" do
      expect(described_class.all).to be_a(Array).and all(be_an described_class)
    end
  end

  describe ".new" do
    it "does not raise" do
      expect { described_class.new(name) }.not_to raise_error
    end

    context "when the component cannot be found" do
      it "raise ArgumentError" do
        expect { described_class.new("foobarbuz") }.to raise_error ArgumentError
      end
    end
  end

  describe "#name" do
    it "is aht" do
      expect(c.name).to eq "aht"
    end
  end

  describe "#org" do
    it "is esp-idf-lib" do
      expect(c.org).to eq org
    end
  end

  describe "#fqdn" do
    it "is esp-idf-lib/aht" do
      expect(c.fqdn).to eq "#{org}/#{name}"
    end
  end

  describe "#issues_url" do
    it "starts with github url and ends with issues" do
      expect(c.issues_url).to end_with("/issues").and start_with("https://github.com")
    end
  end

  describe "#badge_svg_url" do
    it "ends with file.yml/badge.svg" do
      expect(c.badge_svg_url("foo.yml")).to eq "https://github.com/#{org}/#{name}/actions/workflows/foo.yml/badge.svg"
    end
  end

  describe "#esp_component_url" do
    it "matches esp component registry URL" do
      expect(c.esp_component_url).to eq "https://components.espressif.com/components/#{org}/#{name}"
    end
  end

  describe "#eil" do
    it "returns hash" do
      expect(c.eil).to be_a Hash
    end

    it "has name" do
      expect(c.eil).to have_key "name"
    end
  end

  describe "#contributors" do
    it "returns array of contributors" do
      expect(c.contributors).to all(be_a String)
    end
  end

  describe "#contributed_by?" do
    context "when UncleRus is given" do
      it "returns true" do
        expect(c.contributed_by?("UncleRus")).to be true
      end
    end
  end

  describe "#groups" do
    it "returns Array of groups" do
      expect(c.groups).to be_a(Array).and all(be_an String)
    end
  end

  describe "#group_of?" do
    it "returns true" do
      expect(c.group_of?(c.groups.first)).to be true
    end
  end

  describe "#description" do
    it "returns String" do
      expect(c.description).to be_a String
    end
  end

  describe "#version" do
    it "returns String" do
      expect(c.version).to be_a String
    end
  end

  describe "#run" do
    it "runs a command" do
      expect(c.run("echo ok").first).to eq "ok\n"
    end
  end

  describe "#versions" do
    it "returns all versions" do
      expect(c.versions).to be_a Array
    end

    it "returns Array of Semantic::Version" do
      expect(c.versions).to all(be_a Semantic::Version)
    end

    specify "the versions are sorted" do
      versions = ["1.0.0", "2.0.0", "0.0.1"].join("\n")
      allow(Open3).to receive(:capture3).and_return(versions)
      result = c.versions.map(&:to_s)

      expect(result).to eq(["2.0.0", "1.0.0", "0.0.1"])
    end

    context "when no versions are found" do
      it "returns empty Array" do
        allow(Open3).to receive(:capture3).and_return("")

        expect(c.versions).to be_empty
      end
    end

    context "when a tag has a prefix, 'v'" do
      it "removes 'v'" do
        allow(Open3).to receive(:capture3).and_return("v1.0.0\n")

        expect(c.versions).to contain_exactly(Semantic::Version.new("1.0.0"))
      end
    end

    context "when versions include non-semver" do
      it "does not raise" do
        allow(Open3).to receive(:capture3).and_return("foo\n")

        expect { c.versions }.not_to raise_error
      end
    end
  end

  describe "#latest_version" do
    it "returns the latest version" do
      versions = ["1.0.0", "2.0.0", "0.0.1"].join("\n")
      allow(Open3).to receive(:capture3).and_return(versions)

      expect(c.latest_version.to_s).to eq "2.0.0"
    end
  end
end
