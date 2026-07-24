# Compte de test
user = User.find_or_create_by!(email: "test@imagenx.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
end

puts "Test user created: test@imagenx.com / password"

# Compte admin
admin = User.find_or_create_by!(email: "mail@sylvaincavalier.com") do |u|
  u.password = "AdminPasswordToChange"
  u.password_confirmation = "AdminPasswordToChange"
  u.name = "Sylvain Cavalier"
  u.admin = true
  u.skip_confirmation!
end
admin.update!(admin: true) unless admin.admin?
admin.confirm unless admin.confirmed?

puts "Admin user created: mail@sylvaincavalier.com / AdminPasswordToChange"

# Quelques presets de prompt
presets = [
  { name: "Cinematic",
    prompt_text: "Cinematic photography, dramatic lighting, shallow depth of field, 8k, ultra detailed", aspect_ratio: "16:9" },
  { name: "Anime", prompt_text: "Anime style illustration, vibrant colors, detailed linework, studio ghibli inspired",
    aspect_ratio: "3:4" },
  { name: "Pixel Art", prompt_text: "Pixel art style, retro 16-bit aesthetic, clean pixels, vibrant palette",
    aspect_ratio: "1:1" },
  { name: "Oil Painting",
    prompt_text: "Classical oil painting style, rich textures, renaissance lighting, museum quality", aspect_ratio: "4:3" }
]

presets.each do |attrs|
  user.prompt_presets.find_or_create_by!(name: attrs[:name]) do |p|
    p.prompt_text = attrs[:prompt_text]
    p.aspect_ratio = attrs[:aspect_ratio]
  end
end

puts "#{presets.size} prompt presets created"
