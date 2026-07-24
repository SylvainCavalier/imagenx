module Api
  module Admin
    class StatsController < BaseController
      def show
        render json: {
          free_users_count: User.free.count,
          paid_users_count: User.paid.count,
          total_logins: User.sum(:sign_in_count),
          recent_logins_7d: User.where(last_sign_in_at: 7.days.ago..).count,
          total_images_generated: GenerationItem.where(status: "completed").count,
          avg_images_per_batch: average(GenerationItem.group(:generation_batch_id).count),
          avg_images_per_user: average(completed_items_by_user),
          avg_saved_images_per_folder: average(SavedImage.group(:image_folder_id).count),
          top_active_users: top_active_users(10)
        }
      end

      private

      def average(grouped_counts)
        values = grouped_counts.values
        return 0.0 if values.empty?

        (values.sum.to_f / values.size).round(2)
      end

      def completed_items_by_user
        GenerationItem
          .where(status: "completed")
          .joins(:generation_batch)
          .group("generation_batches.user_id")
          .count
      end

      def top_active_users(limit)
        User
          .joins(:generation_batches)
          .group("users.id")
          .order(Arel.sql("COUNT(generation_batches.id) DESC"))
          .limit(limit)
          .pluck("users.id", "users.email", "users.name", Arel.sql("COUNT(generation_batches.id)"))
          .map { |id, email, name, batch_count| { id: id, email: email, name: name, batch_count: batch_count } }
      end
    end
  end
end
