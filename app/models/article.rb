class Article < ActiveRecord::Base
    searchkick autocomplete: ['title']
end
