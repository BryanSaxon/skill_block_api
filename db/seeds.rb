# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# When a new model is added, add a corresponding section below.

# ── Organizations ──────────────────────────────────────────────────────────────

skill_block = Organization.find_or_create_by!(name: "Skill Block")
acme_plant = Organization.find_or_create_by!(name: "Acme Manufacturing")
apex_plant = Organization.find_or_create_by!(name: "Apex Industries")

puts "Organizations: #{Organization.count}"

# ── Users ──────────────────────────────────────────────────────────────────────

User.find_or_create_by!(email: "bryan@bryansaxon.com") do |u|
  u.first_name = "Bryan"
  u.last_name = "Saxon"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :owner
  u.organization = skill_block
end

User.find_or_create_by!(email: "admin@acmemfg.com") do |u|
  u.first_name = "Alice"
  u.last_name = "Admin"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :admin
  u.organization = acme_plant
end

User.find_or_create_by!(email: "manager@acmemfg.com") do |u|
  u.first_name = "Marcus"
  u.last_name = "Manager"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :manager
  u.organization = acme_plant
end

acme_operator1 = User.find_or_create_by!(email: "operator1@acmemfg.com") do |u|
  u.first_name = "Olivia"
  u.last_name = "Operator"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :operator
  u.organization = acme_plant
end

acme_operator2 = User.find_or_create_by!(email: "operator2@acmemfg.com") do |u|
  u.first_name = "Oscar"
  u.last_name = "Operator"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :operator
  u.organization = acme_plant
end

User.find_or_create_by!(email: "admin@apexindustries.com") do |u|
  u.first_name = "Adrian"
  u.last_name = "Admin"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :admin
  u.organization = apex_plant
end

apex_operator = User.find_or_create_by!(email: "operator@apexindustries.com") do |u|
  u.first_name = "Owen"
  u.last_name = "Operator"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :operator
  u.organization = apex_plant
end

puts "Users: #{User.count}"

# ── Manufacturers ──────────────────────────────────────────────────────────────

rockwell = Manufacturer.find_or_create_by!(name: "Rockwell Automation")
siemens = Manufacturer.find_or_create_by!(name: "Siemens")
fanuc = Manufacturer.find_or_create_by!(name: "FANUC")
abb = Manufacturer.find_or_create_by!(name: "ABB Robotics")

puts "Manufacturers: #{Manufacturer.count}"

# ── Machines ───────────────────────────────────────────────────────────────────

conveyor_a = Machine.find_or_create_by!(manufacturer: rockwell, model_number: "1336-B030-EAD-L6-HA2") do |m|
  m.name = "PowerFlex Belt Conveyor"
  m.description = "Variable-speed belt conveyor drive with integrated safety relay. Rated for 30 HP continuous operation."
end

conveyor_b = Machine.find_or_create_by!(manufacturer: siemens, model_number: "SIMATIC-ET200SP-CV1") do |m|
  m.name = "SIMATIC Roller Conveyor"
  m.description = "Modular roller conveyor with ET 200SP distributed I/O. Supports up to 500 kg load per section."
end

robot_arm = Machine.find_or_create_by!(manufacturer: fanuc, model_number: "M-20iD/35") do |m|
  m.name = "M-20iD Articulated Robot"
  m.description = "6-axis articulated robot arm with 35 kg payload. Used for pick-and-place and assembly tasks."
end

welding_robot = Machine.find_or_create_by!(manufacturer: abb, model_number: "IRB-1600-10/1.45") do |m|
  m.name = "IRB 1600 Welding Robot"
  m.description = "High-speed welding robot with 10 kg payload and 1.45 m reach. Optimized for arc welding cells."
end

cnc_mill = Machine.find_or_create_by!(manufacturer: fanuc, model_number: "ROBODRILL-D21MiB5") do |m|
  m.name = "ROBODRILL CNC Machining Center"
  m.description = "Compact CNC vertical machining center with 21-tool magazine. Spindle speed up to 24,000 RPM."
end

plc = Machine.find_or_create_by!(manufacturer: siemens, model_number: "6ES7-315-2EH14-0AB0") do |m|
  m.name = "SIMATIC S7-300 PLC"
  m.description = "Programmable logic controller for mid-range automation tasks. Supports PROFIBUS and PROFINET."
end

puts "Machines: #{Machine.count}"

# ── Organization Machines ──────────────────────────────────────────────────────

# Acme Manufacturing machines
acme_conveyor1 = OrganizationMachine.find_or_create_by!(organization: acme_plant, vin: "RKW-CV-2019-00142") do |om|
  om.machine = conveyor_a
  om.nickname = "Line 1 Conveyor"
end

acme_conveyor2 = OrganizationMachine.find_or_create_by!(organization: acme_plant, vin: "SIE-CV-2021-00387") do |om|
  om.machine = conveyor_b
  om.nickname = "Line 2 Conveyor"
end

acme_robot = OrganizationMachine.find_or_create_by!(organization: acme_plant, vin: "FNC-RB-2022-00051") do |om|
  om.machine = robot_arm
  om.nickname = "Assembly Cell A"
end

acme_cnc = OrganizationMachine.find_or_create_by!(organization: acme_plant, vin: "FNC-CNC-2020-00899") do |om|
  om.machine = cnc_mill
  om.nickname = "Machining Bay 1"
  om.status = "maintenance"
end

acme_plc = OrganizationMachine.find_or_create_by!(organization: acme_plant, vin: "SIE-PLC-2018-04412") do |om|
  om.machine = plc
  om.nickname = "Main Control Panel"
  om.status = "inactive"
end

# Apex Industries machines
apex_welder = OrganizationMachine.find_or_create_by!(organization: apex_plant, vin: "ABB-WR-2023-00017") do |om|
  om.machine = welding_robot
  om.nickname = "Weld Station 1"
end

apex_conveyor = OrganizationMachine.find_or_create_by!(organization: apex_plant, vin: "RKW-CV-2020-00278") do |om|
  om.machine = conveyor_a
  om.nickname = "Outfeed Conveyor"
end

apex_robot = OrganizationMachine.find_or_create_by!(organization: apex_plant, vin: "FNC-RB-2021-00103") do |om|
  om.machine = robot_arm
  om.nickname = "Pack & Place Robot"
end

puts "Organization Machines: #{OrganizationMachine.count}"

# ── User Organization Machines ─────────────────────────────────────────────────

# Assign Acme operators to their machines
UserOrganizationMachine.find_or_create_by!(user: acme_operator1, organization_machine: acme_conveyor1)
UserOrganizationMachine.find_or_create_by!(user: acme_operator1, organization_machine: acme_conveyor2)
UserOrganizationMachine.find_or_create_by!(user: acme_operator1, organization_machine: acme_plc)

UserOrganizationMachine.find_or_create_by!(user: acme_operator2, organization_machine: acme_robot)
UserOrganizationMachine.find_or_create_by!(user: acme_operator2, organization_machine: acme_cnc)

# Assign Apex operator to their machines
UserOrganizationMachine.find_or_create_by!(user: apex_operator, organization_machine: apex_welder)
UserOrganizationMachine.find_or_create_by!(user: apex_operator, organization_machine: apex_conveyor)
UserOrganizationMachine.find_or_create_by!(user: apex_operator, organization_machine: apex_robot)

puts "User Organization Machines: #{UserOrganizationMachine.count}"
