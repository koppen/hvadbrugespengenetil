# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[7.2]
  def self.up
    create_table :accounts do |t|
      t.string :name
      t.string :key
      t.decimal :amount
      t.integer :year
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
