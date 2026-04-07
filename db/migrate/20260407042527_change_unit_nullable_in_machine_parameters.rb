class ChangeUnitNullableInMachineParameters < ActiveRecord::Migration[8.1]
  def change
    change_column_null :machine_parameters, :unit, true
  end
end
