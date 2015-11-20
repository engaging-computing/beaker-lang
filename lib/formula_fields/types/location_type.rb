module FormulaFields
  class LocationType < BaseType
    def initialize(lat, lon)
      if lat.nil? or lon.nil?
        super(nil)
      else
        super([lat, lon])
      end
    end

    def type
      :location
    end

    def to_s
      self.is_nothing? ? '' : "(#{@value[0]}, #{value[1]})"
    end

    def self.distance(l1t, l2t)
      if l1t.is_nothing? or l2t.is_nothing?
        NumberType.new(nil)
      else
        x1t = l1t.get[1]
        x2t = l2t.get[1]
        y1t = l1t.get[0]
        y2t = l2t.get[0]

        x1 = (Math::PI * x1t) / 180
        x2 = (Math::PI * x2t) / 180
        dx = x2 - x1

        y1 = (Math::PI * y1t) / 180
        y2 = (Math::PI * y2t) / 180
        dy = y2 - y1

        a = (Math.sin(dy / 2)**2) + Math.cos(y1) * Math.cos(y2) * (Math.sin(dx / 2)**2)
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

        NumberType.new(c)
      end
    end
  end
end
