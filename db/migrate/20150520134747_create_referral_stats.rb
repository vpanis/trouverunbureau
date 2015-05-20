class CreateReferralStats < ActiveRecord::Migration
  def self.up
    execute <<-SQL
    CREATE MATERIALIZED VIEW referral_stats
    AS (
        SELECT venues.id as venue_id,
               CASE
                WHEN owner_stats.total_invitations_count = 0 THEN 1
                WHEN owner_stats.total_invitations_count IS NULL THEN 1
                ELSE (owner_stats.accepted_count::float / owner_stats.total_invitations_count::float) + 1
               END as multiplier
        FROM venues
        LEFT JOIN (
          SELECT invited_by_id as inviter_id,
                 invited_by_type as inviter_type,
                 COUNT(invitation_accepted_at) as accepted_count,
                 COUNT(invitation_created_at) as sent_invitations_count,
                 total_invitations.total_invitations as total_invitations_count
          FROM users,
               (
                  SELECT COUNT(invitation_accepted_at) as total_invitations
                  FROM users
                  WHERE invitation_accepted_at >= (select date_trunc('day', NOW() - interval '1 month'))
               ) AS total_invitations
          WHERE ( users.invitation_accepted_at IS NULL
            OR  users.invitation_accepted_at >= (select date_trunc('day', NOW() - interval '1 month')))
            AND users.invited_by_id IS NOT NULL
          GROUP BY invited_by_id, invited_by_type, total_invitations.total_invitations
        ) AS owner_stats
        ON venues.owner_id = owner_stats.inviter_id AND venues.owner_type = owner_stats.inviter_type
    );
   SQL
  end
  def self.down
    execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS referral_stats
    SQL
  end
end
