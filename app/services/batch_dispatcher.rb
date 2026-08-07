# Enqueues the generation jobs of a batch.
#
# Regular batches fan out immediately, staggered to stay under the provider rate limit.
# Coherent batches cannot: their followers need the reference image URL, so only the
# reference item is enqueued here and GenerateImageJob enqueues the rest once it is done.
class BatchDispatcher
  STAGGER = 12.seconds

  class << self
    def dispatch_initial(batch)
      return dispatch_all(batch.generation_items.ordered) unless batch.coherent?

      master = batch.reference_item
      GenerateImageJob.perform_later(master.id) if master
    end

    def dispatch_followers(batch)
      dispatch_all(batch.follower_items.where(status: "pending"))
    end

    private

    def dispatch_all(items)
      items.each_with_index do |item, idx|
        GenerateImageJob.set(wait: idx * STAGGER).perform_later(item.id)
      end
    end
  end
end
