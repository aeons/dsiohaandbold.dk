module Filters
    def array_to_sentence(array)
        connector = "og"
        case array.length
        when 0
            ""
        when 1
            array[0].to_s
        when 2
            "#{array[0]} #{connector} #{array[1]}"
        else
            "#{array[0...-1].join(', ')} #{connector} #{array[-1]}"
        end
    end

    def positive_plus(input)
        input = "+#{input}" if input > 0
        input
    end
end

Liquid::Template.register_filter(Filters)