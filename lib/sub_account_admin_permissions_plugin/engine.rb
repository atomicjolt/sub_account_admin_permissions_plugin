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
    config.to_prepare do
      Canvas::Plugin.register(:otc_sub_account_admin_permissions, nil, {
        name: "OTC Sub-Account Admin Permissions",
        author: "Atomic Jolt",
        description: "Enables allowing sub-accounts to manage user login details",
        version: "1.1.0",
        select_text: "OTC Sub-Account Admin Permisisons",
        settings_partial: 'sub_account_admin_permissions_plugin/plugin_settings'
      })
      if ActiveRecord::Base.connection.table_exists?('plugin_settings') && Canvas::Plugin.find(:otc_sub_account_admin_permissions).enabled?
        # In development we have to force loading RoleOverride first, so the
        # default permissions are registered
        RoleOverride

        User

        Permissions.register(
          become_user: {
            label: -> { "Act as users" },
            label_v2: -> { "Users - act as" },
            account_only: true,
            true_for: %w[AccountAdmin],
            available_to: %w[AccountAdmin AccountMembership],
          }
        )

        module UserExtension
          def can_masquerade?(masquerader, account)

            # Get a list of all the accounts that the user's courses
            # are contained within. This is used to determine if the
            # user can masquerade as a user in a sub-account.
            # This will result in n + 1 queries but it is cached
            accounts = courses.map(&:associated_accounts).flatten.uniq

            # Get all the accounts that the masquerader is an admin of
            admin_accounts = masquerader.account_users.active.preload(:account).map(&:account)
            intersection = accounts & admin_accounts

            # If the masqureader is an admin in one of the parent accounts of
            # the user's courses, then they can masquerade as the user
            if intersection.length > 0
              account = intersection.last

              # We have to fake root_account privileges for the
              # sub-account or Canvas will normally always return false
              def account.root_account?
                true
              end
            end

            super(masquerader, account)
          end
        end

        class ::User < ActiveRecord::Base
          prepend UserExtension
        end
      end
    end
  end
end
