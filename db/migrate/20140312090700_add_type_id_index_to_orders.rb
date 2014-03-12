class AddTypeIdIndexToOrders < ActiveRecord::Migration
  def change
    add_index :orders, [:type, :id]
  end
end
