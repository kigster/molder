require 'molder/version'
require 'require_dir'
module Molder
  RequireDir.enable_require_dir!(self, __FILE__)

  dir_r 'molder'
end


