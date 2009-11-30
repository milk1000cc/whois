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


require 'socket'
require 'timeout'


module Whois

  class Client

    # The maximum time to run a WHOIS query expressed in seconds
    DEFAULT_TIMEOUT = 5

    attr_accessor :timeout


    # Initializes a new Whois::Client with <tt>options</tt>.
    # 
    # If block is given, yields self.
    # 
    #   client = Whois::Client.new do |c|
    #     c.timeout = nil
    #   end
    #   client.query("google.com")
    #
    # @param  [Hash] options the options to create a <tt>Client</tt> with.
    # @option options [Float] :timeout (DEFAULT_TIMEOUT) The maximum time to run a WHOIS query expressed in seconds
    # @return Whois::Client a new client with given <tt>options</tt>
    # @yield  [self] a block to perform any extra initialization on the object
    # @yieldparam [Whois::Client] self the newly initialized client object
    #
    def initialize(options = {}, &block)
      self.timeout = options[:timeout] || DEFAULT_TIMEOUT
      yield(self) if block_given?
    end


    class Query # :nodoc
      # IPv6?
      # RPSL?
      # email?
      # NSIC?
      # ASP32?
      # IP?
      # domain?
      # network?
    end
    
    
    # Queries the right whois server for <tt>qstring</tt> and returns
    # a <tt>Whois::Answer</tt> instance containing the response from the server.
    #
    #   Whois.query("google.com")
    #   # => #<Whois::Answer>
    #
    # This is equivalent to
    #
    #   Whois::Client.new.query("google.com")
    #   # => #<Whois::Answer>
    #
    # @param  [String] qstring the query string
    # @return [Whois::Answer] the answer returned by the WHOIS server
    #
    def query(qstring)
      Timeout::timeout(timeout) do
        @server = Server.guess(qstring)
        @server.query(qstring)
      end
    end
      
  end

end