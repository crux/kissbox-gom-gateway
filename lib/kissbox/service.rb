module Kissbox

  class Service < Gom::Remote::Entry
    
    Defaults = { }

    attr_reader :path

    def initialize path, options = {}
      @path = path
      @options = (Defaults.merge options)

      #@values_sub = Subscription.new(
      #  "#{@path}/values", 
      #  :name => "enttec-dmx", :operations => [:update, :create]
      #)
      #@values_sub.callback = lambda { |*args| value_gnp(*args) }
      #connection.subscribe @values_sub
    end
  end
end
