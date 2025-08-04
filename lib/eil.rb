require "pathname"
require_relative "eil/version"

class EIL
  def self.root
    Pathname.new(__FILE__).parent.parent
  end
end

require_relative "eil/component"
require_relative "eil/groups"
require_relative "eil/person"
