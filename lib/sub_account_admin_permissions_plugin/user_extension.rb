module SubAccountAdminPermissionsPlugin
  module UserExtension
    extend ActiveSupport::Concern

    included do
      alias_method :canvas_can_masquerade?, :can_masquerade?

      def can_masquerade?(masquerader, account)
        # Skip modificatiosn for root admins
        return canvas_can_masquerade?(masquerader, account) if masquerader.root_admin_for?(account)

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
