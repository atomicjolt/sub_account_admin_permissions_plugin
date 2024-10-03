module SubAccountAdminPermissionsPlugin
  module PermissionOverrides
    def self.manage_user_logins
      Permissions.register(
        manage_user_logins: {
          :label => lambda { I18n.t('permissions.manage_user_logins', "Modify login details for users") },
          :label_v2 => lambda { I18n.t("Users - manage login details") },
          :available_to => [
            'AccountAdmin',
            'AccountMembership'
          ],
          :account_only => true,
          :true_for => [
            'AccountAdmin'
          ]
        }
      )
    end


    def self.become_user
      Permissions.register(
        become_user: {
          label: -> { "Act as users" },
          label_v2: -> { "Users - act as" },
          account_only: true,
          true_for: %w[AccountAdmin],
          available_to: %w[AccountAdmin AccountMembership],
        }
      )

      ::User.include SubAccountAdminPermissionsPlugin::UserExtension
    end
  end
end
