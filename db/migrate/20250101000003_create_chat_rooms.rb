class CreateChatRooms < ActiveRecord::Migration[8.1]
  def change
    unless table_exists?(:chat_rooms)
      create_table :chat_rooms do |t|
        t.references :user1, null: false, foreign_key: { to_table: :users }
        t.references :user2, null: true, foreign_key: { to_table: :users }
        t.string :status, default: 'waiting'

        t.timestamps
      end
    end

    # Add indexes only if they don't exist (references creates them, but in case migration partially ran)
    add_index :chat_rooms, :user1_id unless index_exists?(:chat_rooms, :user1_id)
    add_index :chat_rooms, :user2_id unless index_exists?(:chat_rooms, :user2_id)
  end
end

