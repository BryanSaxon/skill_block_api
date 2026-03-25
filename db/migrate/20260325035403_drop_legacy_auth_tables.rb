class DropLegacyAuthTables < ActiveRecord::Migration[8.1]
  def change
    drop_table :jwt_denylists
    drop_table :password_reset_tokens
  end
end
