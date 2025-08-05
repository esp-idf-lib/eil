# frozen_string_literal: true

require "open3"
require "yaml"

class EIL
  # A class represents esp-idf-lib components
  class Component
    @git_submodule_result = ""

    ORG = "esp-idf-lib"
    GITHUB_URL = "https://github.com"
    GITHUB_PAGES_URL = "https://esp-idf-lib.github.io"
    ESP_COMPONENT_REGISTRY_URL = "https://components.espressif.com"

    attr_reader :name

    def initialize(name)
      @name = name.chomp
      raise ArgumentError, "#{@name} cannot be found" unless self.class.git_submodule_names.include? name
    end

    def path
      EIL.root / "components" / name
    end

    def org
      ORG
    end

    def fqdn
      "#{org}/#{name}"
    end

    def repo_url
      "#{GITHUB_URL}/#{fqdn}"
    end

    def esp_url
      "#{ESP_COMPONENT_REGISTRY_URL}/components/#{fqdn}"
    end

    def doc_url
      "#{GITHUB_PAGES_URL}/#{name}"
    end

    def issues_url
      "#{repo_url}/issues"
    end

    def badge_svg_url(workflow_file)
      "#{workflow_url(workflow_file)}/badge.svg"
    end

    def workflow_url(workflow_file)
      "#{repo_url}/actions/workflows/#{workflow_file}"
    end

    def badge(workflow_file)
      workflow_name = workflow_file.split(".").first
      "[![#{workflow_name}](#{badge_svg_url(workflow_file)})](#{workflow_url(workflow_file)})"
    end

    def esp_component_url
      "#{ESP_COMPONENT_REGISTRY_URL}/components/#{fqdn}"
    end

    def badge_esp_component_svg_url
      "#{esp_component_url}/badge.svg"
    end

    def badge_esp_component_registry
      # [![Component Registry](https://components.espressif.com/components/esp-idf-lib/hmc5883l/badge.svg)](https://components.espressif.com/components/esp-idf-lib/hmc5883l)
      "[![Component Registry](#{badge_esp_component_svg_url})](#{esp_component_url})"
    end

    def eil
      return @eil if @eil

      @eil = YAML.safe_load_file(path / ".eil.yml")
    end

    ##
    # Reload .eil.yml and refresh the state of the object. Call this method if
    # .eil.yml might have been changed.
    def reload
      @eil = nil
    end

    def contributors
      eil["copyrights"].map { |c| c["name"] }
    end

    def contributed_by?(name)
      contributors.include? name
    end

    def groups
      eil["groups"]
    end

    def group_of?(group)
      eil["groups"].include? group
    end

    def description
      eil["description"]
    end

    def version
      eil["version"]
    end

    # Returns Array of all components as EIL::Component
    #
    # @return [Array<EIL::Component>]
    def self.all
      git_submodule_names.map { |name| Component.new(name) }
    end

    # Runs `git submodule`. The output of the command is cached so that
    # multiple calls do not run the command multiple times.
    #
    # @return [String] The output of the command
    # @raise [RuntimeError] When the command fails
    def self.git_submodule
      # if cache is not empty, use cache
      git_submodule_result = instance_variable_get(:@git_submodule_result)
      return git_submodule_result unless git_submodule_result.empty?

      stdout = nil
      Dir.chdir EIL.root do
        stdout, stderr, status = Open3.capture3("git submodule")
        raise "failed to run `git submodule`: #{stderr}" unless status.success?
      end

      # keep the result in cache
      instance_variable_set(:@git_submodule_result, stdout)
      stdout
    end

    # Finds all components from git submodule command and returns Array of
    # component names.
    #
    # @return [iArray<String>]
    def self.git_submodule_names
      name = []
      git_submodule.each_line(chomp: true) do |line|
        # 1d24b0da13e9c0aae9ad985e4348d2fe50263e3c components/tda74xx (1.0.3-2-g1d24b0d)
        component_path = line.split[1]
        next unless component_path.start_with? "components"

        name << component_path.split("/")[1]
      end
      name.sort
    end
  end
end
