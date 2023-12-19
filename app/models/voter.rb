class Voter < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: [:cnic, :kid, :name, :father_name],
    using: { tsearch: { any_word: true, prefix: true } }
end
