class CreateChatMessages < ActiveRecord::Migration[8.1]
  def change
    unless table_exists?(:chat_messages)
      create_table :chat_messages do |t|
        t.references :chat_room, null: false, foreign_key: true
        t.references :user, null: false, foreign_key: true
        t.text :content

        t.timestamps
      end
    end

    add_index :chat_messages, :chat_room_id unless index_exists?(:chat_messages, :chat_room_id)
    add_index :chat_messages, :user_id unless index_exists?(:chat_messages, :user_id)
  end
end

