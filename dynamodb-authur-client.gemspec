# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dynamodb-authur-client/version"

Gem::Specification.new do |s|
  s.name        = "dynamodb-authur-client"
  s.version     = Dynamodb::Authur::Client::VERSION
  s.authors     = ["Matthew Moore", "Rohen Peterson"]
  s.email       = ["matt@crowdmob.com", "rohen@crowdmob.com"]
  s.homepage    = "https://github.com/crowdmob/dynamodb-authur-client"
  s.summary     = %q{Client-side of the distributed authentication solution for Rails with Warden, using DynamoDB as a session store.}
  s.description = %q{Client-side of the distributed authentication solution for Rails with Warden, using DynamoDB as a session store.}

  s.rubyforge_project = "dynamodb-authur-client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("warden", "~> 1.1.1")
  s.add_dependency("railties", "~> 3.1")
end
