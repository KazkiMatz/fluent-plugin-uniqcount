# -*- coding: utf-8 -*-

require 'securerandom'
require_relative 'queue'
require_relative 'list'

module UniqCount
  class ListContainer
    attr_reader :_id

    def initialize(config)
      @_id = SecureRandom.hex
      @config = config
      @queue = Queue.new
      @list = List.new
      @mutex = Mutex.new
      @flashed_at = nil
    end

    def need_flush?(now)
      @flashed_at.nil? or now - @flashed_at >= @config['out_interval']
    end

    def last_flash
      @flashed_at
    end

    def insert(es)
      items = []
      es.each do |time, record|
        time = @config['time'] ? record[@config['time']] : time
        key1 = record[@config['key1']]
        key2 = @config['key2'] ? record[@config['key2']] : nil

        items << [time, key1, key2] if time && key1
      end

      items.sort_by!(&:first)
      @mutex.synchronize {
        @queue.push(items)
      }
    end

    # @param now [Integer] the unix timestamp,
    #  to which list and queue are synchronized
    def flush(now)
      @mutex.synchronize {
        @flashed_at = now
        till = now - @config['offset']
        items = @queue.fetch(till)
        @queue.shift(till)

        @list.add(items)
        @list.shift(till - @config['span'])
      }
    end

    def get
      @mutex.synchronize {
        [@config['out_tag'], {
          '_id' => @_id,
          'label' => @config['label'],
          'ranks' => @list.get(@config['out_num']),
          'at' => @flashed_at,
        }]
      }
    end

    def clear(key1)
      @mutex.synchronize {
        @list.clear(key1)
      }
    end
  end
end
