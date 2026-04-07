class MigrateUserRoles < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :role_tmp, :string
    execute "UPDATE users SET role_tmp = CASE role WHEN 0 THEN 'admin' WHEN 1 THEN 'admin' WHEN 2 THEN 'manager' WHEN 3 THEN 'operator' END"
    execute "UPDATE users SET role = CASE role_tmp WHEN 'admin' THEN 0 WHEN 'manager' THEN 1 WHEN 'operator' THEN 2 END"
    remove_column :users, :role_tmp
    change_column_default :users, :role, 2
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
