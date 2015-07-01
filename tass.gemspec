require File.expand_path('../lib/tapjoy/autoscaling_bootstrap/version', __FILE__)
Gem::Specification.new do |s|
  s.name                  = 'tass'
  s.version               = Tapjoy::AutoscalingBootstrap::VERSION
  s.date                  = '2015-06-16'
  s.summary               = 'Tapjoy Autoscaling Suite'
  s.description           = 'TASS is the suite of tools that the Tapjoy Operations team uses to manage autoscaling groups and launch configurations.'
  s.authors               = ['Ali Tayarani']
  s.email                 = 'ali.tayarani@tapjoy.com'
  s.files                 = Dir['lib/tapjoy/**/**']
  s.homepage              = 'https://github.com/Tapjoy/tass'
  s.license               = 'MIT'
  s.executables           = ['tass']
  s.required_ruby_version = '~> 2.0'
  s.add_runtime_dependency('trollop',  '~> 2.1')
  s.add_runtime_dependency('highline', '~> 1.0')
  s.add_runtime_dependency('aws-sdk', '~> 2.0')
  s.add_runtime_dependency('hashdiff', '~> 0.2.2')
  s.add_development_dependency('rspec', '~> 3.2')
  s.add_development_dependency('activesupport', '~> 4.2')
  s.add_development_dependency('webmock', '~> 1.20')
  s.add_development_dependency('vcr', '~> 2.9')
end
