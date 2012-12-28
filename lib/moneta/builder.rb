module Moneta
  # Builder implements the DSL to build a stack of Moneta store proxies
  # @api private
  class Builder
    # @yieldparam Builder dsl code block
    def initialize(&block)
      raise ArgumentError, 'No block given' unless block_given?
      @proxies = []
      instance_eval(&block)
    end

    # Build proxy stack
    #
    # @return [Object] Generated Moneta proxy stack
    # @api public
    def build
      klass, options, block = @proxies.first
      @proxies[1..-1].inject([klass.new(options, &block)]) do |stores, proxy|
        klass, options, block = proxy
        stores << klass.new(stores.last, options, &block)
      end
    end

    # Add proxy to stack
    #
    # @param [Symbol or Class] proxy Name of proxy class or proxy class
    # @param [Hash] options Options hash
    # @api public
    def use(proxy, options = {}, &block)
      proxy = Moneta.const_get(proxy) if Symbol === proxy
      raise ArgumentError, 'You must give a Class or a Symbol' unless Class === proxy
      @proxies.unshift [proxy, options, block]
      nil
    end

    # Add adapter to stack
    #
    # @param [Symbol] name Name of adapter class
    # @param [Hash] options Options hash
    # @api public
    def adapter(name, options = {}, &block)
      use(Adapters.const_get(name), options, &block)
    end
  end
end
