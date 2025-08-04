# frozen_string_literal: true

require "pathname"

# The core class of EIL.
class EIL
  @root = Pathname.new(".")

  class << self
    attr_reader :root
  end

  def self.root=(path)
    @root = Pathname.new(path)
  end
end

require_relative "eil/version"
require_relative "eil/component"
require_relative "eil/groups"
require_relative "eil/person"
