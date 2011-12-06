# -*- encoding : utf-8 -*-
class Matrix
  def multiplication_mod_2(m)
    case(m)
    when Numeric
      rows = @rows.collect {|row|
        row.collect {|e| (e * m) % 2 }
      }
      return new_matrix rows, column_size
    when Vector
      m = Matrix.column_vector(m)
      r = self.multiplication_mod_2 m
      return r.column(0)
    when Matrix
      Matrix.Raise ErrDimensionMismatch if column_size != m.row_size

      rows = Array.new(row_size) {|i|
        Array.new(m.column_size) {|j|
          (0 ... column_size).inject(0) do |vij, k|
            vij + self[i, k] * m[k, j]
          end % 2
        }
      }
      return new_matrix rows, m.column_size
    else
      return apply_through_coercion(m, __method__)
    end
  end
end
