class AddIndexToWord < ActiveRecord::Migration[6.0]
  def change
    add_index :words, :word
  end
end
