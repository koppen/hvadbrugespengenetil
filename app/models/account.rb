class Account < ActiveRecord::Base

  default_scope order(:key)

end
