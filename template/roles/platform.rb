name "platform"
description "A basic Ubuntu system"

run_list(%w(
  recipe[apt]
  recipe[build-essential]
  recipe[user::data_bag]
))
