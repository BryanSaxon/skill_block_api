# db/seeds.rb — idempotent seed data for all environments
# Runs with: bin/rails db:seed

# ── Admin Organization (Skill Block) ─────────────────────────────────────────

skill_block = Organization.find_or_create_by!(name: "Skill Block") do |o|
  o.org_type = :admin
end
skill_block.update!(org_type: :admin) unless skill_block.admin?

puts "Organizations: #{Organization.count}"

# ── Skill Block admin user ────────────────────────────────────────────────────

User.find_or_create_by!(email: "bryan@bryansaxon.com") do |u|
  u.first_name = "Bryan"
  u.last_name = "Saxon"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :admin
  u.organization = skill_block
end

# ── Demo: AluMix 3000 machine ─────────────────────────────────────────────────

alumi_tech = Manufacturer.find_or_create_by!(name: "AluMi Tech")

alumix = Machine.find_or_create_by!(manufacturer: alumi_tech, model_number: "ALX-3000-B") do |m|
  m.name = "AluMix 3000"
  m.description = "Industrial batch mixer for aluminum alloy compounds. " \
                  "Capacity 200 kg, variable-speed drum, integrated temperature monitoring."
end

puts "Machines: #{Machine.count}"

# ── Demo: Contoso Manufacturing (client org) ──────────────────────────────────

contoso = Organization.find_or_create_by!(name: "Contoso Manufacturing") do |o|
  o.org_type = :client
end

# Demo personas
User.find_or_create_by!(email: "david@contosomfg.com") do |u|
  u.first_name = "David"
  u.last_name = "Chen"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :admin
  u.organization = contoso
end

sandra = User.find_or_create_by!(email: "sandra@contosomfg.com") do |u|
  u.first_name = "Sandra"
  u.last_name = "Rivera"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :manager
  u.organization = contoso
end

carlos = User.find_or_create_by!(email: "carlos@contosomfg.com") do |u|
  u.first_name = "Carlos"
  u.last_name = "Mendez"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :operator
  u.organization = contoso
  u.manager = sandra
end

puts "Users: #{User.count}"

# ── Demo: Line 4 Mixer (organization machine) ─────────────────────────────────

line4 = OrganizationMachine.find_or_create_by!(organization: contoso, vin: "ALX-2023-L4-001") do |om|
  om.machine = alumix
  om.nickname = "Line 4 Mixer"
end

# Assign Carlos to Line 4
UserOrganizationMachine.find_or_create_by!(user: carlos, organization_machine: line4)

puts "Organization Machines: #{OrganizationMachine.count}"

# ── Demo: Machine Parameters (8 from MVP Plan) ────────────────────────────────

parameters = [
  {
    name: "drum_speed",
    unit: "RPM",
    normal_min: 40,
    normal_max: 120,
    warning_threshold: 30,
    critical_threshold: 135,
    display_order: 1
  },
  {
    name: "motor_temperature",
    unit: "°C",
    normal_min: 55,
    normal_max: 85,
    warning_threshold: 95,
    critical_threshold: 105,
    display_order: 2
  },
  {
    name: "drum_temperature",
    unit: "°C",
    normal_min: 20,
    normal_max: 75,
    warning_threshold: 80,
    critical_threshold: nil,
    display_order: 3
  },
  {
    name: "torque",
    unit: "Nm",
    normal_min: 150,
    normal_max: 400,
    warning_threshold: 450,
    critical_threshold: nil,
    display_order: 4
  },
  {
    name: "batch_weight",
    unit: "kg",
    normal_min: 80,
    normal_max: 200,
    warning_threshold: 220,
    critical_threshold: nil,
    display_order: 5
  },
  {
    name: "vibration_rms",
    unit: "mm/s",
    normal_min: 0,
    normal_max: 4.5,
    warning_threshold: 6,
    critical_threshold: 9,
    display_order: 6
  },
  {
    name: "cycle_phase",
    unit: "",
    normal_min: nil,
    normal_max: nil,
    warning_threshold: nil,
    critical_threshold: nil,
    display_order: 7
  },
  {
    name: "cycle_count",
    unit: "",
    normal_min: nil,
    normal_max: nil,
    warning_threshold: nil,
    critical_threshold: nil,
    display_order: 8
  }
]

parameters.each do |params|
  MachineParameter.find_or_create_by!(
    organization_machine: line4,
    name: params[:name]
  ) do |p|
    p.unit = params[:unit]
    p.normal_min = params[:normal_min]
    p.normal_max = params[:normal_max]
    p.warning_threshold = params[:warning_threshold]
    p.critical_threshold = params[:critical_threshold]
    p.display_order = params[:display_order]
  end
end

puts "Machine Parameters: #{MachineParameter.count}"
puts ""
puts "Demo credentials:"
puts "  Admin:    david@contosomfg.com   / password"
puts "  Manager:  sandra@contosomfg.com  / password"
puts "  Operator: carlos@contosomfg.com  / password"
puts "  Machine:  Line 4 Mixer (id: #{line4.id})"
