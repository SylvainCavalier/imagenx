# Idempotent setup of the Stripe catalog (Products + Prices) for the credits/subscription
# system. Safe to re-run: Stripe Prices are immutable, so existence is checked by
# `lookup_key` and only missing ones are created. Talks to whichever Stripe account/mode
# the current STRIPE_SECRET_KEY points to (live in this app as of writing) — running this
# creates real, permanent catalog objects, so it's a one-time setup action, not something
# to run repeatedly or from CI.
namespace :stripe do
  desc "Create the ImageNX Stripe Products/Prices (credits top-ups + subscription) if missing"
  task setup: :environment do
    credits_product = find_or_create_product("ImageNX Credits", "imagenx-credits")
    subscription_product = find_or_create_product("ImageNX Subscription", "imagenx-subscription")

    topup_packs = {
      "topup_300" => 300,
      "topup_500" => 500,
      "topup_1000" => 1000,
      "topup_2000" => 2000
    }

    topup_packs.each do |lookup_key, unit_amount|
      find_or_create_price(
        lookup_key: lookup_key,
        product: credits_product,
        unit_amount: unit_amount,
        recurring: nil
      )
    end

    find_or_create_price(
      lookup_key: "subscription_monthly",
      product: subscription_product,
      unit_amount: 500,
      recurring: { interval: "month" }
    )
  end

  def find_or_create_product(name, metadata_tag)
    existing = Stripe::Product.list(active: true).data.find { |p| p.metadata["app"] == "imagenx" && p.metadata["tag"] == metadata_tag }
    if existing
      puts "Product '#{name}' already exists (#{existing.id})"
      return existing
    end

    product = Stripe::Product.create(name: name, metadata: { app: "imagenx", tag: metadata_tag })
    puts "Created product '#{name}' (#{product.id})"
    product
  end

  def find_or_create_price(lookup_key:, product:, unit_amount:, recurring:)
    existing = Stripe::Price.list(lookup_keys: [lookup_key], active: true).data.first
    if existing
      puts "Price '#{lookup_key}' already exists (#{existing.id})"
      return existing
    end

    params = {
      product: product.id,
      unit_amount: unit_amount,
      currency: "eur",
      lookup_key: lookup_key
    }
    params[:recurring] = recurring if recurring

    price = Stripe::Price.create(params)
    puts "Created price '#{lookup_key}' (#{price.id}) — #{unit_amount / 100.0}€#{recurring ? '/month' : ''}"
    price
  end
end
