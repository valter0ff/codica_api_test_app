# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :description

      t.timestamps
    end
    add_index :projects, %i[user_id title], unique: true
  end
end
