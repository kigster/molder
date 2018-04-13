module Molder
  VERSION = '0.1.5'.freeze
  DESCRIPTION = <<-eof
Molder is a command line tool for generating and running (in parallel, across a configurable number of processes) a set of related but similar commands that are generated based on a merge of a template with a set of attributes. A key use-case is auto-generation of the host provisioning commands for an arbitrary cloud environment. The gem is not constrained to any particular cloud tool or even a command, and can be used to generate a consistent set of commands based on several customizable dimensions. For example, you could generate 600 provisioning commands for hosts in EC2, numbered from 1 to 100, constrained to the dimensions "zone-id" (values: ["a", "b", "c"]) and the data center "dc" (values: ['us-west2', 'us-east1' ]).
  eof
    .gsub(/\s{2,}/, ' ')
end
