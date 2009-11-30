#
# = Ruby Whois
#
# An intelligent pure Ruby WHOIS client and parser.
#
#
# Category::    Net
# Package::     Whois
# Author::      Simone Carletti <weppos@weppos.net>
# License::     MIT License
#
#--
#
#++


require 'whois/answer/parser'
require 'whois/answer/parser/base'


module Whois

  #
  # = Answer
  #
  # Contains all the responses returned by all the WHOIS servers
  # queries by the <tt>Whois::Client</tt> for a specific query string.
  #
  class Answer

    # Holds the server adapter used to perform the WHOIS query.
    # The instance is a specific subclass of <tt>Whois::Server::Adapters::Base</tt>.
    # @return [Whois::Server::Adapters::Base] the server adapter used to perform the WHOIS query
    attr_reader :server

    # Holds all the <tt>Whois::Answer::Part</tt>s this response is composed of.
    # @return [Array<Whois::Answer::Part>]
    attr_reader :parts


    def initialize(server, parts)
      @parts  = parts
      @server = server
    end

    
    # Returns a <tt>String</tt> representation of <tt>self</tt>.
    #
    # @return [String]
    def to_s
      content.to_s
    end
    
    # Returns a <tt>String</tt> containing a human-redable
    # representation of <tt>self</tt>.
    #
    # @return [String]
    def inspect
      content.inspect
    end
    
    # Invokes <tt>String#match</tt> on answer <tt>content</tt>
    # and returns the <tt>MatchData</tt> or <tt>nil</tt>.
    #
    # @param  [String, Regexp] pattern the pattern to match against
    # @return [MatchData, NilClass] the MatchData if <tt>content</tt> matches <tt>pattern</tt>, <tt>nil</tt> otherwise
    # @see    Whois::Answer#content
    # @see    Whois::Answer#match?
    # @see    String#match
    def match(pattern)
      content.match(pattern)
    end
    
    # Checks for equality between <tt>self</tt> and <tt>other</tt>.
    #
    # @param  [Whois::Answer, String] other
    # @return [Boolean] Returns <tt>true</tt> if the <tt>object</tt> is the same object,
    #         or is a <tt>String</tt> and has the same content.
    def ==(other)
      (other.equal?(self)) ||
      # This option should be deprecated
      (other.instance_of?(String) && other == self.to_s) ||
      (other.instance_of?(Answer) && other.to_s == self.to_s)
    end
    
    # Delegates to ==.
    # @see Whois::Answer#==
    def eql?(other)
      self == other
    end


    # Returns the content of this <tt>Answer</tt> as a <tt>String</tt>.
    # This method joins all <tt>Answer</tt>'s parts into a single <tt>String</tt>
    # and separates each response with a newline character.
    #
    #   answer = Whois::Answer.new([Whois::Answer::Part.new("First answer.")])
    #   answer.content
    #   # => "First answer."
    #
    #   answer = Whois::Answer.new([Whois::Answer::Part.new("First answer."), Whois::Answer::Part.new("Second answer.")])
    #   answer.content
    #   # => "First answer.\nSecond answer."
    #
    # @return [String] all <tt>Answer</tt> parts joined into a single <tt>String</tt>
    def content
      @content ||= parts.map { |part| part.response }.join("\n")
    end

    # Returns whether this <tt>Answer</tt> changed compared to <tt>other</tt>.
    #
    # Comparing the <tt>Answer</tt> contents is not always as trivial as it seems.
    # WHOIS servers sometimes inject dynamic information into the WHOIS <tt>Answer</tt>,
    # such as the timestamp the request was generated.
    # This causes two answers to be different even if they actually should be considered equal
    # because the registry data didn't change.
    #
    # This method should provide a bulletproof way to detect whether this <tt>Answer</tt>
    # changed if compared with <tt>other</tt>.
    #
    # @param  [Whois::Answer] other
    # @return [Boolean]
    # @see    Whois::Answer#unchanged?
    def changed?(other)
      !unchanged?(other)
    end

    # The opposite of <tt>changed?</tt>.
    #
    # @param  [Whois::Answer] other
    # @return [Boolean]
    # @see    Whois::Answer#changed?
    def unchanged?(other)
      self == other ||
      parser.unchanged?(other.parser)
    end


    # Invokes <tt>match</tt> and returns <tt>true</tt> if <tt>pattern</tt>
    # matches <tt>content</tt>, <tt>false</tt> otherwise.
    #
    # @param  [String, Regexp] pattern the pattern to match against
    # @return [Boolean]
    # @see    Whois::Answer#match
    def match?(pattern)
      !content.match(pattern).nil?
    end


    # Lazy-loads and returns a <tt>Whois::Answer::Parser</tt> proxy for current answer.
    #
    # @return [Whois::Answer::Parser]
    def parser
      @parser ||= Parser.new(self)
    end

    # Returns <tt>true</tt> if the <tt>property</tt> passed as symbol
    # is supported by any available parser for this answer.
    # See also <tt>Whois::Answer::Parser.supported?</tt>.
    def property_supported?(property)
      parser.property_supported?(property)
    end

    # @deprecated Use {#property_supported?} instead.
    def supported?(*args)
      ::Whois.deprecate "supported? is deprecated. Use property_supported? instead."
      property_supported?(*args)
    end


    protected
      
      # Delegates all method calls to the internal parser.
      def method_missing(method, *args, &block)
        if Parser.properties.include?(method)
          parser.send(method, *args, &block)
        else
          super
        end
      end
      
  end

end