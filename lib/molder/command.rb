module Molder
  class Command
    attr_accessor :name, :config, :desc, :supervise, :concurrent, :examples, :args

    def initialize(name:, config:, desc:, supervise: true, concurrent: true, examples: [], args:)
      self.name       = name
      self.config     = config
      self.desc       = desc
      self.supervise  = supervise
      self.concurrent = concurrent
      self.examples   = examples
      self.args       = args
    end

  end
end
