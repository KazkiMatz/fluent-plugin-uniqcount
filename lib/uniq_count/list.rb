# -*- coding: utf-8 -*-

require_relative 'heap'

module UniqCount
  class List
    def initialize
      @global_wal = Queue.new
      @table = {}
      comparator = ->(item){item[:key2_uniq_count]}
      @heap = Heap.new(comparator)
    end

    def get(n)
      @heap.first(n).each_with_index.map {|item, i|
        {'key1' => item[:key1], 'rank' => i, 'key2_uniq_count' => item[:key2_uniq_count]}
      }
    end

    # @param items [Array] array of log entries, sorted by time
    def add(items)
      keys_to_resort = {}

      @global_wal.push(items)

      items.each do |item|
        time, key1, key2 =* item
        unless @table[key1]
          @table[key1] = {
            key1: key1,
            wal: [],
            key2_appearances: {},
            key2_uniq_count: 0,
          }
          @heap.add(@table[key1])
        end

        key1_table = @table[key1]
        key2_appearances = key1_table[:key2_appearances]

        unless key2_appearances[key2]
          key2_appearances[key2] = []
          key1_table[:key2_uniq_count] += 1
        end
        key2_appearances[key2] << time

        @heap.update(key1_table)
      end
    end

    # @param till [Integer] the unix timestamp,
    #  items before that point in the list will be cut off
    def shift(till)
      @global_wal.shift(till).each do |time, key1, key2|
        key1_table = @table[key1]
        key2_appearances = key1_table[:key2_appearances]

        key2_appearances[key2].delete_at(key2_appearances[key2].index(time))
        if key2_appearances[key2].length == 0
          key2_appearances.delete(key2)
          key1_table[:key2_uniq_count] -= 1
        end

        if key1_table[:key2_uniq_count] == 0
          @heap.remove(key1_table)
          @table.delete(key1)
        else
          @heap.update(key1_table)
        end
      end
    end
  end
end
