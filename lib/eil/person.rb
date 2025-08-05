# frozen_string_literal: true

class EIL
  # A class to represents people contributed to the project.
  #
  # All methods except name might return nil.
  class Person
    attr_reader :name, :person

    # @param [String] name Name, the key in persons.yml.
    # @raise [ArgumentError] when the person cannot found in persons.yml.
    def initialize(name)
      @name = name
      @person = self.class.yaml.select { |p| p["name"] == name }.first
      raise ArgumentError, "cannot find #{name} in #{EIL.root / "persons.yml"}" unless @person
    end

    # Full name
    #
    # @return [String]
    def full_name
      person["full_name"]
    end

    # GitHub ID
    #
    # @return [String]
    def gh_id
      person["gh_id"]
    end

    # email
    #
    # @return [String]
    def email
      person["email"]
    end

    # url
    #
    # @return [String]
    def url
      person["url"]
    end

    # Components the person contributed to
    #
    # @return [Array<EIL::Component>]
    def contributed_components
      Component.all.select { |c| c.contributed_by? name }
    end

    def self.yaml
      persons = YAML.safe_load_file(EIL.root / "persons.yml")
      persons.sort do |a, b|
        name_a = a.key?("full_name") ? a["full_name"] : a["name"]
        name_b = b.key?("full_name") ? b["full_name"] : b["name"]
        name_a <=> name_b
      end
    end

    # Returns all persons sorted by name
    #
    # @return [Array<EIL::Person>]
    def self.all
      yaml.map { |n| new n["name"] }
    end
  end
end
