# -*- coding: utf-8 -*-

module UniqCount
  class Queue
    def initialize
      @data = []
    end

    def fetch(till)
      @data.first(length(till))
    end

    def size
      @data.size
    end

    def push(items)
      return unless items.length > 0
      resort_needed = tail_time && tail_time > items.first[0]
      @data.concat(items)
      sort if resort_needed
    end

    def sort
      @data.sort_by!(&:first)
    end

    def shift(till)
      @data.shift(length(till))
    end

    def clear(key1)
      @data.delete_if {|time, _key1, _key2|
        key1 == _key1
      }
    end

    protected

    def head_time
      @data.first ? @data.first[0] : nil
    end

    def tail_time
      @data.last ? @data.last[0] : nil
    end

    def length(till)
      i = 0
      while item = @data[i] and item[0] < till do; i += 1; end
      i
    end
  end
end
