module Molder
    class MolderError < StandardError; end
    class InvalidCommandError < MolderError; end
    class InvalidTemplateName < MolderError; end
end
