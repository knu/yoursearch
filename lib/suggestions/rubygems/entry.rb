class Suggestions::Rubygems::Entry < ActiveRecord::Base
  self.table_name = 'rubygems'

  default_scope { where(generation: 1) }
  scope :importing, ->{ where(generation: 2) }

  class << self
    def import
      transaction {
        unscoped {
          where.not(generation: 1).delete_all
        }
        importing.scoping {
          yield
        }
        unscoped {
          update_all('generation = generation - 1')
          where.not(generation: 1).delete_all
        }
        self
      }
    end
  end
end
