module SubAccountAdminPermissionsPlugin
  module UserExtension
    extend ActiveSupport::Concern

    included do
      alias_method :canvas_can_masquerade?, :can_masquerade?

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

        canvas_can_masquerade?(masquerader, account)
      end
    end
  end
end
