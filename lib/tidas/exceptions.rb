module Tidas
  ###################
  # Wrap Exceptions #
  ###################
  class TidasError < StandardError
  end

  class ParameterError < TidasError
  end

  class ConfigurationError < TidasError
  end
end
