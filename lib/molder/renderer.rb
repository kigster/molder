require 'fileutils'
require 'liquid'
require 'hashie'
require 'colored2'

class Symbol
  def to_liquid
    to_i
  end
end

module Molder
  #
  # == Usage
  #
  # Generally you first generate a set of parameters (a nested hash) that
  # represents configuration of your application. As was mentioned above, the
  # parameter hash can be self-referential – it will be automatically expanded.
  #
  # Once you create a Renderer instance with a given parameter set, you can then
  # use the +#render+ method to convert content with Renderer placeholers into a
  # fully resolved string.
  #
  # == Example
  #/
  #    require 'molder/renderer'
  #
  #    params = { 'invitee' => 'Adam',
  #                 'extra' => 'Eve',
  #            'salutation' => 'Dear {{ invitee }} & {{ extra }}',
  #                 'from'  => 'Jesus'
  #    }
  #    @Renderer = ::Molder::Renderer.new(params)
  #    ⤷ #<Molder::Renderer:0x007fb90b9c32d8>
  #    content = '{{ salutation }}, please attend my birthday. Sincerely, {{ from }}.'
  #    ⤷ {{ salutation }}, please attend my birthday. Sincerely, {{ from }}.
  #    @Renderer.render(content)
  #     ⤷ "Dear Adam & Eve, please attend my birthday. Sincerely, Jesus."
  #
  # == Troubleshooting
  #
  # See errors documented under this class.
  #
  class Renderer

    # When the parameter hash contains a circular reference, this
    # error will be thrown. It is thrown after the params hash is attempted
    # to be expanded MAX_RECURSIONS times.
    class TooManyRecursionsError < StandardError;
    end

    # When a Renderer (or params) contain a reference that can not be resolved
    # this error is raised.
    class UnresolvedReferenceError < ArgumentError;
    end

    # During parameter resolution phase (constructor) this error indicates that
    # internal representation of the params hash (YAML) no longer compiles after
    # some parameters have been resolved. This would be an internal error that
    # should be coded around and fixed as a bug if it ever to occur.
    class SyntaxError < StandardError;
    end

    MAX_RECURSIONS = 100

    attr_accessor :template

    # Create Renderer object, while storing and auto-expanding params.
    def initialize(template)
      self.template = template
    end

    # Render given content using expanded params.
    def render(params)
      attributes      = expand_arguments(Hashie.stringify_keys(params.to_h))
      liquid_template = Liquid::Template.parse(template)
      liquid_template.render(attributes, { strict_variables: true }).tap do
        unless liquid_template.errors.empty?
          raise LiquidTemplateError, "#{liquid_template.errors.map(&:message).join("\n")}"
        end
      end.gsub(/\n/, ' ').gsub(/\s{2,}/, ' ').strip
    rescue ArgumentError => e
      raise UnresolvedReferenceError.new(e)
    end

    private

    def expand_arguments(params)
      current    = YAML.dump(params)
      recursions = 0

      while current =~ %r[{{\s*[a-z_]+\s*}}]
        recursions += 1
        raise TooManyRecursionsError.new if recursions > MAX_RECURSIONS
        previous = current
        current  = ::Liquid::Template.parse(previous).render(params)
      end

      begin
        Hashie::Mash.new(YAML.load(current))
      rescue Psych::SyntaxError => e
        STDERR.puts "Error parsing YAML Renderer:\n" +
                      e.message.red +
                      "\n#{current}"
        raise SyntaxError.new(e)
      end
    end
  end
end
