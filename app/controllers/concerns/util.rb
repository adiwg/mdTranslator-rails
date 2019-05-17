module Util
  extend ActiveSupport::Concern

  def sanitize(input)
    gem_root = ADIWG::MdjsonSchemas::Utils.schema_dir.match(/(^.+)\/lib/i).captures[0]
    gem_path = File.join(gem_root, 'schema')
    gem_path[0] = gem_path[0].downcase

    input.gsub(gem_path, '...')
  end

  def each_recur(arr, &block)
    arr.each_with_index do |elem, idx|
      if elem.is_a? Array
        each_recur(elem, &block)
      else
        yield elem, idx, arr
      end
    end
  end

  def format_plain(h, out = '')
    h.each do |v|
      value = h.is_a?(Hash) ? v[1] : v

      if value.is_a?(Hash) || value.is_a?(Array)
        out += "#{v[0]}:\n" if value.is_a?(Hash)
        out += format_plain(value)
      else
        # if array, just display the  value
        out += h.is_a?(Hash) ? "#{v[0]}: #{value}\n" : "    #{v}\n"
      end
    end
    out
  end
end
