class AddOrgTypeToOrganizations < ActiveRecord::Migration[8.1]
  def up
    add_column :organizations, :org_type, :integer, null: false, default: 1
    add_index :organizations, :org_type
    execute "CREATE UNIQUE INDEX index_organizations_one_admin ON organizations (org_type) WHERE org_type = 0"
    execute "UPDATE organizations SET org_type = 0 WHERE name = 'Skill Block'"
  end

  def down
    execute "DROP INDEX IF EXISTS index_organizations_one_admin"
    remove_index :organizations, :org_type
    remove_column :organizations, :org_type
  end
end
