# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.string :status, default: 'new', index: true, null: false

      t.timestamps
    end
  end
end
