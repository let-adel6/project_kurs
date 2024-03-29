class CreateSubscribers < ActiveRecord::Migration[6.1]
  def change
    create_table :subscribers do |t|
      t.integer :chat_id

      t.timestamps
    end
  end
end
