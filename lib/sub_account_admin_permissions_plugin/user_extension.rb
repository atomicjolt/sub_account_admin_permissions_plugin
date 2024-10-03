module SubAccountAdminPermissionsPlugin
  module UserExtension
    extend ActiveSupport::Concern

    included do
      alias_method :canvas_can_masquerade?, :can_masquerade?

      def can_masquerade?(masquerader, account)
        # Skip modifications for root admins
        return canvas_can_masquerade?(masquerader, account) if masquerader.root_admin_for?(account)

        # Retrieve a list of all accounts associated with the user's courses.
        # The masqqerader must be an admin of one of these accounts to masquerade as the user.
        # Note: This results in n + 1 queries, but it is cached.
        accounts = courses.map(&:associated_accounts).flatten.uniq

        # Get all the accounts that the masquerader is an admin of
        admin_accounts = masquerader.account_users.active.preload(:account).map(&:account)
        intersection = accounts & admin_accounts

        # Find any accounts that the masquerader is an admin of
        # that contains the user's courses. This is the account
        # that we'll need to make permission checks against
        if intersection.length > 0
          account = intersection.last

          # We have to fake root_account privileges for the
          # sub-account or Canvas will normally always return false
          def account.root_account?
            true
          end
        end

        # We then call the original method as
        # it actually does the checking if the user has the
        # permissions that are required to masquerade as a user
        canvas_can_masquerade?(masquerader, account)
      ensure
        # We don't want this method to persist past this call
        # As active record may cache the object and cause issues
        if intersection.length > 0
          account.singleton_class.remove_method(:root_account?)
        end
      end
    end
  end
end
