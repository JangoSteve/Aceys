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
