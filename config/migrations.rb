# Sample migrations borrowed from https://github.com/Mercurius3/vrijewadlopers/blob/master/config/migrations.rb
#
# migration "create the tours table" do
#   database.create_table :tours do
#     primary_key :id
#     String      :name
#     String      :slug
#     Text        :description
#     Integer     :duration
#     Float       :price
#     String      :level
#     DateTime    :date
#     Integer     :length
#     foreign_key :calendar_id, :calendars
#   end
# end
# 
# 
# migration "create the calendars table" do
#   database.create_table :calendars do
#     primary_key :id
#     DateTime    :date
#     String      :name
#     String      :info
#     foreign_key :tour_id, :tours
#   end
# end

migration "create companies table" do
  database.create_table :companies do
    primary_key :id
    DateTime    :date
    String      :name
    Integer     :votes_count
    String      :preferred_spelling
  end
end

migration "create spellings table" do
  database.create_table :spellings do
    primary_key :id
    DateTime    :date
    String      :name
    Integer     :votes_count
    foreign_key :company_id, :companies
  end
end

migration "create votes table" do
  database.create_table :votes do
    primary_key :id
    DateTime    :date
    String      :email
    foreign_key :company_id, :companies
    foreign_key :spelling_id, :spellings
  end
end

# DELETE ALL DATA AND START OVER
[:votes,:spellings,:companies].each do |table|
  database[table].delete
end
