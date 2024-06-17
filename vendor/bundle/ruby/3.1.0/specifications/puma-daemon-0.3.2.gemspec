# -*- encoding: utf-8 -*-
# stub: puma-daemon 0.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "puma-daemon".freeze
  s.version = "0.3.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/kigster/puma-daemon/blob/master/CHANGELOG.md", "homepage_uri" => "https://github.com/kigster/puma-daemon", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/kigster/puma-daemon" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Konstantin Gredeskoul".freeze]
  s.bindir = "exe".freeze
  s.date = "2023-06-22"
  s.description = "\nIn version 5.0 the authors of the popular Ruby web server Puma chose to remove the \ndaemonization support from Puma, because the code wasn't wall maintained,\nand because other and better options exist for production deployments. For example\nsystemd, Docker/Kubernetes, Heroku, etc. \n\nHaving said that, it was neat and often useful to daemonize Puma in development.\nThis gem adds this support to Puma 5 & 6 (hopefully) without breaking anything in Puma\nitself.\n\nSo, if you want to use the latest and greatest Puma 5+, but prefer to keep using built-in\ndaemonization, this gem if for you.\n".freeze
  s.email = ["kigster@gmail.com".freeze]
  s.executables = ["pumad".freeze]
  s.files = ["exe/pumad".freeze]
  s.homepage = "https://github.com/kigster/puma-daemon".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.4.13".freeze
  s.summary = "Restore somewhat Puma's ability to self-daemonize, since Puma 5.0 dropped it".freeze

  s.installed_by_version = "3.5.13".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<puma>.freeze, [">= 5.0".freeze])
  s.add_runtime_dependency(%q<rack>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<asciidoctor>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<codecov>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<httparty>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<relaxed-rubocop>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec-its>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<yard>.freeze, [">= 0".freeze])
end
