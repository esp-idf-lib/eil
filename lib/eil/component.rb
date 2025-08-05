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

    # Create an {EIL::Component} object.
    #
    # @raise [ArgumentError] When name is not found in the components.
    def initialize(name)
      @name = name.chomp
      raise ArgumentError, "#{@name} cannot be found" unless self.class.git_submodule_names.include? name
    end

    # Path to the component's root directory.
    #
    # @return [Pathname]
    def path
      EIL.root / "components" / name
    end

    # GitHub Organization name.
    #
    # @return [String]
    def org
      ORG
    end

    # `{org}/{name}`
    #
    # @return [String]
    def fqdn
      "#{org}/#{name}"
    end

    # Repository URL.
    #
    # @return [String]
    def repo_url
      "#{GITHUB_URL}/#{fqdn}"
    end

    # URL to the documentation.
    #
    # @return [String]
    def doc_url
      "#{GITHUB_PAGES_URL}/#{name}"
    end

    # URL to the Issues.
    #
    # @return [String]
    def issues_url
      "#{repo_url}/issues"
    end

    # URL to a badge SVG image.
    #
    # @param [String] workflow_file The workflow file name
    # @return [String]
    def badge_svg_url(workflow_file)
      "#{workflow_url(workflow_file)}/badge.svg"
    end

    # URL to a workflow page on GitHub.
    #
    # @param [String] workflow_file The workflow file name
    # @return [String]
    def workflow_url(workflow_file)
      "#{repo_url}/actions/workflows/#{workflow_file}"
    end

    # Markdown markup to show a badge of a workflow.
    #
    # @param [String] workflow_file Workflow file name.
    # @return [String]
    def badge(workflow_file)
      workflow_name = workflow_file.split(".").first
      "[![#{workflow_name}](#{badge_svg_url(workflow_file)})](#{workflow_url(workflow_file)})"
    end

    # URL to component page on ESP Component Repository
    #
    # @return [String]
    def esp_component_url
      "#{ESP_COMPONENT_REGISTRY_URL}/components/#{fqdn}"
    end

    # URL to a SVG badge image of ESP Component Repository
    #
    # @return [String]
    def badge_esp_component_svg_url
      "#{esp_component_url}/badge.svg"
    end

    # Markdown markup to show a badge of a component on ESP Component
    # Repository.
    #
    # @return [String]
    def badge_esp_component_registry
      # [![Component Registry](https://components.espressif.com/components/esp-idf-lib/hmc5883l/badge.svg)](https://components.espressif.com/components/esp-idf-lib/hmc5883l)
      "[![Component Registry](#{badge_esp_component_svg_url})](#{esp_component_url})"
    end

    # Returns `.eil.yml` as a Hash.
    #
    # @return [Hash] the content of the file
    def eil
      return @eil if @eil

      @eil = YAML.safe_load_file(path / ".eil.yml")
    end

    # Reload .eil.yml and refresh the state of the object. Call this method if
    # `.eil.yml` might have been changed.
    def reload
      @eil = nil
    end

    # Array of personis who contributed to the component found in `copyrights`
    #
    # @return [Array<String>]
    def contributors
      eil["copyrights"].map { |c| c["name"] }
    end

    # Returns true if name contributed to the component.
    #
    # @param [String] name name of the person
    def contributed_by?(name)
      contributors.include? name
    end

    # A short cut to eil["groups"]
    def groups
      eil["groups"]
    end

    # Returns true if group is included in groups
    def group_of?(group)
      eil["groups"].include? group
    end

    # A short cut to eil["description"]
    #
    # @return [String]
    def description
      eil["description"]
    end

    # A short cut to eil["version"]
    #
    # @return [String]
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
