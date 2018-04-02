module Molder
  class Configuration
    class << self
      def default_config
        'spec/fixtures/knife-ec2.yml'.freeze
      end
    end
  end
end
