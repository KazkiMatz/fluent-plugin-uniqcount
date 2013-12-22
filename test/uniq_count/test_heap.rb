require 'helper'

class HeapTest < Test::Unit::TestCase
  def setup
  end

  def test_heap_operations
    comparator = ->(item1, item2){ item1[:count] <=> item2[:count] }
    h = UniqCount::Heap.new(comparator)

    assert_equal nil, h.pick
    assert_equal nil, h.first
    assert_equal [], h.first(10)

    a = {count: 1}
    b = {count: 0}

    h.add(a)
    assert_equal 1, h.length
    assert_equal a, h.first
    assert_equal [a], h.first(1)
    assert_equal [a], h.first(10)

    h.pop
    assert_equal 0, h.length
    assert_equal nil, h.first

    h.add(a)
    assert_equal 1, h.length
    assert_equal a, h.first

    h.remove(a)
    assert_equal 0, h.length
    assert_equal nil, h.first

    h.add(a)
    h.add(b)
    assert_equal 2, h.length
    h.remove(b)
    assert_equal 1, h.length
    assert_equal a, h.first
  end

  def test_heap_sort
    comparator = ->(item1, item2){ item1[:count] <=> item2[:count] }
    h = UniqCount::Heap.new(comparator)

    (0..49).to_a.shuffle.each{|i|h.add({count: i})}

    assert_equal [1,2], h.children_idx(0)
    assert_equal [5,6], h.children_idx(2)
    assert_equal [47, 48], h.children_idx(23)
    assert_equal [49], h.children_idx(24)
    assert_equal [], h.children_idx(25)

    (40..49).to_a.reverse.each {|i|
      assert_equal i, h.pick[:count]
    }

    assert_equal 39, h.first[:count]
    assert_equal (30..39).to_a.reverse, h.first(10).map{|item| item[:count]}
    (40..49).to_a.shuffle.each{|i|h.add({count: i})}
    assert_equal (30..49).to_a.reverse, h.first(20).map{|item| item[:count]}
  end

  def test_heap_add
    comparator = ->(item1, item2){ item1[:count] <=> item2[:count] }
    h = UniqCount::Heap.new(comparator)

    items = []
    1000.times do
      items << {count: rand(100)}
    end

    items.each do |item|
      h.add(item)

      top_n = h.first(20)
      top_n.inject{|last, item|
        assert last[:count] >= item[:count],
          "got #{top_n.map{|item|item[:count]}.inspect}"
        item
      }
    end

    assert_equal 1000, h.length
  end

  def test_heap_update
    comparator = ->(item1, item2){ item1[:count] <=> item2[:count] }
    h = UniqCount::Heap.new(comparator)

    items = []
    1000.times do
      items << {count: rand(100), added: false, updated: false}
    end

    3000.times do
      item = items.sample
      if item[:updated]
        item[:added] = false
        item[:updated] = false
        h.remove(item)
      elsif item[:added]
        item[:updated] = true
        item[:count] = rand(1000)
        h.update(item)
      else
        item[:added] = true
        h.add(item)
      end

      top_n = h.first(20)
      top_n.inject{|last, item|
        assert last[:count] >= item[:count],
          "got #{top_n.map{|item|item[:count]}.inspect} from #{h.length}"
        item
      }
    end

    assert h.length <= 1000
  end

  def test_heap_item_identification
    comparator = ->(item1, item2){ item1[:count] <=> item2[:count] }
    h = UniqCount::Heap.new(comparator)

    a = {count: 0}
    b = {count: 0}
    c = {count: 0}

    h.add(a)
    h.add(b)
    h.add(c)

    assert_equal 3, h.length

    a[:count] = 1
    b[:count] = 3
    c[:count] = 2
    h.update(a)
    h.update(b)
    h.update(c)
  end
end
