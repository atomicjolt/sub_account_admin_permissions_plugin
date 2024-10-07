# Copyright (C) 2019 Atomic Jolt

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module SubAccountAdminPermissionsPlugin
  class Engine < ::Rails::Engine
    config.autoload_paths << File.expand_path(File.join(__FILE__, "../.."))
    config.eager_load_paths << File.expand_path(File.join(__FILE__, "../.."))

    config.to_prepare do
      Canvas::Plugin.register(:otc_sub_account_admin_permissions, nil, {
        name: "OTC Sub-Account Admin Permissions",
        author: "Atomic Jolt",
        description: "Enables allowing sub-accounts to manage user login details",
        version: "1.2.0",
        select_text: "OTC Sub-Account Admin Permisisons",
        settings_partial: 'sub_account_admin_permissions_plugin/plugin_settings'
      })
      if ActiveRecord::Base.connection.table_exists?('plugin_settings') && Canvas::Plugin.find(:otc_sub_account_admin_permissions).enabled?
        @plugin ||= PluginSetting.find_by(name: "otc_sub_account_admin_permissions")

        # In development we have to force loading RoleOverride first, so the
        # default permissions are registered
        RoleOverride

        if @plugin.settings[:subaccount_manage_user_logins] == "true"
          SubAccountAdminPermissionsPlugin::PermissionOverrides.manage_user_logins
        end

        if @plugin.settings[:subaccount_become_user] == "true"
          SubAccountAdminPermissionsPlugin::PermissionOverrides.become_user
        end
      end
    end
  end
end
