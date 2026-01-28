class CreatePairings < ActiveRecord::Migration[8.1]
  def change
    unless table_exists?(:pairings)
      create_table :pairings do |t|
        t.references :user, null: false, foreign_key: true
        t.string :status, default: 'waiting'

        t.timestamps
      end
    end

    add_index :pairings, [:user_id, :status] unless index_exists?(:pairings, [:user_id, :status])
  end
end

