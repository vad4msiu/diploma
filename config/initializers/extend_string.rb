# -*- encoding : utf-8 -*-
class String
  def downcase
    Unicode::downcase(self)
  end
end
