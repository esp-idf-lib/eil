# frozen_string_literal: true

require "pathname"
require_relative "eil/version"

# The core class of EIL.
class EIL
  @root = nil
  def self.root
    raise StandardError, "EIL.root is not defined. Set the repository root by EIL.root = path" unless @root

    @root
  end

  def self.root=(path)
    @root = Pathname.new(path)
  end
end

require_relative "eil/component"
require_relative "eil/groups"
require_relative "eil/person"
