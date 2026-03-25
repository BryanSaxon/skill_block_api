# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# ── Organizations ──────────────────────────────────────────────────────────────

skill_block = Organization.find_or_create_by!(name: "Skill Block")
manufacturer = Organization.find_or_create_by!(name: "Sample Manufacturer")

puts "Organizations: #{Organization.count}"

# ── Users ──────────────────────────────────────────────────────────────────────

User.find_or_create_by!(email: "bryan@bryansaxon.com") do |u|
  u.first_name = "Bryan"
  u.last_name = "Saxon"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :super_admin
  u.organization = skill_block
end

User.find_or_create_by!(email: "admin@skillblock.com") do |u|
  u.first_name = "Admin"
  u.last_name = "User"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :admin
  u.organization = skill_block
end

User.find_or_create_by!(email: "manager@samplemanufacturer.com") do |u|
  u.first_name = "Manager"
  u.last_name = "User"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :manager
  u.organization = manufacturer
end

User.find_or_create_by!(email: "employee@samplemanufacturer.com") do |u|
  u.first_name = "Employee"
  u.last_name = "User"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :employee
  u.organization = manufacturer
end

puts "Users: #{User.count}"
