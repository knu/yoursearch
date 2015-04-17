class CreateRubygems < ActiveRecord::Migration
  def change
    create_table :rubygems do |t|
      t.string :name, null: false
      t.integer :generation, limit: 1, default: 1, null: false
      t.timestamps null: false
    end

    add_index :rubygems, [:name, :generation], unique: true
  end
end
