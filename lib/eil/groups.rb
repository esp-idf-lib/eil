# frozen_string_literal: true

require "yaml"

class EIL
  # A class that represents groups
  class Groups
    def self.all
      YAML.safe_load_file(EIL.root / "groups.yml")
    end
  end
end
