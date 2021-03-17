class CreateWords < ActiveRecord::Migration[6.0]
  def change
    create_table :words do |t|
      t.string :word
      t.integer :count, default: 0
      t.timestamps
    end
  end
end
