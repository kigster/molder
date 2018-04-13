module Molder
  VERSION = '0.2.1'.freeze
  DESCRIPTION = <<-eof
 Molder is a handy command line tool for generating and running (in parallel, 
using a pool of processes with a configurable size) a set of related and yet
different commands. A YAML file defines both the attributes and the command
template, and Molder then merges the two with CLI arguments to give you a
consistent set of commands for, eg. provisioning thousands of virtual hosts 
in a cloud. The gem is not limnited to any particular cloud, tool, or a  
command, and can be used across various domains to generate a consistent set 
of commands based on the YAML-supplied attributes and templates, that might
vary across custom dimensions. For example, you could generate 600 provisioning 
commands for hosts in EC2, numbered from 1 to 100, but constrained to the 
zones "a", "b", "c", and data centers "dc" (values: ['us-west2', 'us-east1' ]). 
Behind the scenes Molder uses another Ruby gem Parallel — for actually running
the provisioning commands.
  eof
    .gsub(/\s{2,}/, ' ')
end
