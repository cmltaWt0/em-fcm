# -*- mode: ruby; encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "em-fcm/version"

Gem::Specification.new do |s|
  s.name        = "em-fcm"
  s.version     = EventMachine::FCM::VERSION
  s.authors     = ["Max K"]
  s.email       = ["misokolsky@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{EventMachine-driven Firebase Google Cloud Messaging (FCM)}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "eventmachine", '~> 1.0.9.1', '>= 1.0.9'
  s.add_dependency "em-http-request", '~> 1.0', '>= 1.0.3'
  s.add_dependency "uuid"
end
