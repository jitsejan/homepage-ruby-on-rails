class Article < ActiveRecord::Base
    searchkick autocomplete: ['title']

    scope :query,                   -> (title) { where("lower(title) = ?", "#{title.downcase.gsub('-', ' ')}").first()}

end
