$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sub_account_admin_permissions_plugin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sub_account_admin_permissions_plugin"
  s.version     = SubAccountAdminPermissionsPlugin::VERSION
  s.authors     = ["David Spencer"]
  s.email       = ["david.spencer@atomicjolt.com"]
  s.homepage    = "https://atomicjolt.com"
  s.summary     = "Overrides some subaccount admin permissions in Canvas"
  s.description = "Overrides some subaccount admin permissions in Canvas"
  s.license     = "AGPL-3.0"

  s.files = Dir["{app,config,db,lib}/**/*"]

  s.add_dependency "rails", "~> 5.1.6", ">= 5.1.6.2"
end
