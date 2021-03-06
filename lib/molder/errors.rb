module Molder
  class MolderError < StandardError; end
  class InvalidCommandError < MolderError; end
  class InvalidTemplateName < MolderError; end
  class ConfigNotFound < MolderError; end
  class LiquidTemplateError < MolderError; end
end
