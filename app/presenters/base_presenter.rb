class BasePresenter

  def initialize(object, template, options = {})
    @object = object
    @template = template
    @options = options
  end

  private

  def self.presents(name)
    define_method(name) do
      @object
    end
  end

  def h
    @template
  end

  def method_missing(*args, &block)
    @template.send(*args, &block)
  end

end
