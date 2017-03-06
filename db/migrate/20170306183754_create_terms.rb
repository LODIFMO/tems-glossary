class CreateTerms < ActiveRecord::Migration
  def change
    create_table :terms do |t|
      t.string :title
      t.string :eng_title
      t.string :description
      t.string :uri

      t.timestamps null: false
    end
  end
end
