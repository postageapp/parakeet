module Parakeet::Support
  # == Module Methods =======================================================

  def self.symbolize_keys(obj)
    case (obj)
    when Hash
      obj.map do |k,v|
        [ k.to_sym, symbolize_keys(v) ]
      end.to_h
    when Array
      obj.map do |e|
        symbolize_keys(e)
      end
    else
      obj
    end
  end
end
