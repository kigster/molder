module ArubaHelpers
  def self.history
    @history ||= ArubaDoubles::History.new(File.join(ArubaDoubles::Double.bindir, ArubaDoubles::HISTORY_FILE))
  end
end

module Molder
  class Configuration
    class << self
      def default_config
        'spec/fixtures/knife-ec2.yml'.freeze
      end
    end
  end
end
