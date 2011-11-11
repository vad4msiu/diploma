require "matrix"
# require "./extend_matrix"
# require 'YAML'

# GENERATE MATRIX
# matrixs = []
# 84.times do
#   rows = []
#   128.times do
#     row = []
#     32.times do
#       row << rand(2)
#     end
#     rows << row
#   end
#   matrixs << Matrix.rows(rows)
# end
# 
# File.new("matrix.yml", "w").write(YAML::dump(matrixs))

module MinWise
  MATRIXS = YAML.load(File.open('././matrix_84_32.yml').read)
  FUNCTION_NUMBER = MATRIXS.size

  def self.find_min hex_numbers
    raise ArgumentError "numbers is Array" unless hex_numbers.is_a?(Array)
    return [] if hex_numbers.empty?
    mins = []
    MATRIXS.map do |matrix|
      binary_array = hex_numbers.first.hex.to_s(2).split("").map!(&:to_i)
      (128 - binary_array.size).times { binary_array.unshift(0) }
      min = (Matrix.row_vector(binary_array).multiplication_mod_2 matrix).to_a.join.to_i(2)
      hex_numbers.each do |hex_number|
        binary_array = hex_number.hex.to_s(2).split("").map!(&:to_i)
        (128 - binary_array.size).times { binary_array.unshift(0) }
        current = (Matrix.row_vector(binary_array).multiplication_mod_2 matrix).to_a.join.to_i(2)
        min = current if min > current
      end
      mins << min
    end
    return mins
  end
end