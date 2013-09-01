module Kernel
  def logger
    @@logger ||= Logger.new(STDOUT)
    @@logger
  end
end
