# -*- encoding: utf-8 -*-
# stub: capistrano-rails 1.1.8 ruby lib

Gem::Specification.new do |s|
  s.name = "capistrano-rails".freeze
  s.version = "1.1.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tom Clements".freeze, "Lee Hambley".freeze, "Kir Shatrov".freeze]
  s.date = "2016-09-13"
  s.description = "Rails specific Capistrano tasks".freeze
  s.email = ["seenmyfate@gmail.com".freeze, "lee.hambley@gmail.com".freeze, "shatrov@me.com".freeze]
  s.homepage = "https://github.com/capistrano/rails".freeze
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Rails specific Capistrano tasks".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>.freeze, ["~> 3.1"])
      s.add_runtime_dependency(%q<capistrano-bundler>.freeze, ["~> 1.1"])
    else
      s.add_dependency(%q<capistrano>.freeze, ["~> 3.1"])
      s.add_dependency(%q<capistrano-bundler>.freeze, ["~> 1.1"])
    end
  else
    s.add_dependency(%q<capistrano>.freeze, ["~> 3.1"])
    s.add_dependency(%q<capistrano-bundler>.freeze, ["~> 1.1"])
  end
end
