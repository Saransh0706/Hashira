require 'json'
require 'rational'  # for Ruby < 2.1; for Ruby >= 2.1 Rational is core class

# Parse JSON file
def parse_json_file(filename)
  JSON.parse(File.read(filename))
end

# Decode a value string with the given base to an Integer
def decode_value(value_str, base)
  Integer(value_str, base)
rescue ArgumentError
  nil
end

# Lagrange interpolation at x=0 to find f(0) (constant term)
# points: array of [x, y] with Integer/Rational values
def lagrange_interpolate_at_zero(points)
  result = Rational(0, 1)

  points.each_with_index do |(xi, yi), i|
    term = Rational(yi)
    points.each_with_index do |(xj, _), j|
      next if i == j
      numerator = Rational(0 - xj)
      denominator = Rational(xi - xj)
      term *= numerator / denominator
    end
    result += term
  end

  result
end

# Main driver
def main(filenames)
  filenames.each do |filename|
    data = parse_json_file(filename)

    keys = data['keys']
    n = keys['n']
    k = keys['k']

    points = []

    data.each do |key, val|
      next if key == 'keys'
      x = key.to_i
      base = val['base'].to_i
      encoded_val = val['value']

      y = decode_value(encoded_val, base)
      if y.nil?
        puts "Warning: Could not decode value #{encoded_val} with base #{base} in #{filename}"
        next
      end

      points << [x, y]
    end

    # Use first k points for interpolation
    points = points.first(k)

    secret = lagrange_interpolate_at_zero(points)

    # If secret is integer, print as integer else as rational
    if secret.denominator == 1
      puts "File: #{filename} -> Secret (constant term c) = #{secret.numerator}"
    else
      puts "File: #{filename} -> Secret (constant term c) = #{secret}"
    end
  end
end

# Example usage with your two JSON files
main(['testcase1.json', 'testcase2.json'])
