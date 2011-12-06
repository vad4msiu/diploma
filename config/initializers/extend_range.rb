# -*- encoding : utf-8 -*-
class Range
  
  # Не очень верные пересечения и объединения!!!
  def intersection(other)
    raise ArgumentError, 'value must be a Range' unless other.kind_of?(Range)

    my_min, my_max = first, last
    other_min, other_max = other.first, other.last

    new_min = self === other_min ? other_min : other === my_min ? my_min : nil
    new_max = self === other_max ? other_max : other === my_max ? my_max : nil

    new_min && new_max ? new_min...new_max : nil
  end

  def union(other)
    raise ArgumentError, 'value must be a Range' unless other.kind_of?(Range)

    my_min, my_max = first, last
    other_min, other_max = other.first, other.last

    return nil if  other_min > my_max || other_max < my_min

    new_min = my_min > other_min ? other_min : my_min
    new_max = my_max > other_max ? my_max : other_max

    return new_min...new_max
  end
  
  alias_method :&, :intersection
  alias_method :|, :union
end
