module Tapjoy
  module AutoscalingBootstrap
    module Version
      MAJOR = 0
      MINOR = 1
      PATCH = 3
    end

    VERSION = [Version::MAJOR, Version::MINOR, Version::PATCH].join('.')
  end
end
