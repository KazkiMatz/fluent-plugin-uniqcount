# -*- coding: utf-8 -*-

class ListTest < Test::Unit::TestCase
  def setup
  end

  def test_uniq_count
    l = UniqCount::List.new
    assert_equal [], l.get(5)

    l.add([[1, 'foo', 1], [1, 'foo', 1]])
    top_n = l.get(10)
    assert_equal 1, top_n.length
    assert_equal 0, top_n[0]['rank']
    assert_equal 'foo', top_n[0]['key1']
    assert_equal 2, top_n[0]['key2_count']
    assert_equal 1, top_n[0]['key2_uniq_count']

    l.add([[1, 'bar', 1], [2, 'bar', 1], [2, 'bar', 2]])
    top_n = l.get(10)
    assert_equal 2, top_n.length
    assert_equal 0, top_n[0]['rank']
    assert_equal 'bar', top_n[0]['key1']
    assert_equal 3, top_n[0]['key2_count']
    assert_equal 2, top_n[0]['key2_uniq_count']
    assert_equal 1, top_n[1]['rank']
    assert_equal 'foo', top_n[1]['key1']
    assert_equal 2, top_n[1]['key2_count']
    assert_equal 1, top_n[1]['key2_uniq_count']

    l.shift(1)

    l.add([[1, 'foo', 3], [3, 'foo', 2]])
    top_n = l.get(10)
    assert_equal 2, top_n.length
    assert_equal 0, top_n[0]['rank']
    assert_equal 'foo', top_n[0]['key1']
    assert_equal 4, top_n[0]['key2_count']
    assert_equal 3, top_n[0]['key2_uniq_count']
    assert_equal 1, top_n[1]['rank']
    assert_equal 'bar', top_n[1]['key1']
    assert_equal 3, top_n[1]['key2_count']
    assert_equal 2, top_n[1]['key2_uniq_count']

    l.shift(2)
    l.add([[4, 'bar', 1]])
    top_n = l.get(10)
    assert_equal 2, top_n.length
    assert_equal 0, top_n[0]['rank']
    assert_equal 'bar', top_n[0]['key1']
    assert_equal 3, top_n[0]['key2_count']
    assert_equal 2, top_n[0]['key2_uniq_count']
    assert_equal 1, top_n[1]['rank']
    assert_equal 'foo', top_n[1]['key1']
    assert_equal 1, top_n[1]['key2_count']
    assert_equal 1, top_n[1]['key2_uniq_count']

    l.shift(3)
    top_n = l.get(10)
    assert_equal 2, top_n.length

    l.shift(4)
    top_n = l.get(10)
    assert_equal 1, top_n.length
    assert_equal 0, top_n[0]['rank']
    assert_equal 'bar', top_n[0]['key1']
    assert_equal 1, top_n[0]['key2_count']
    assert_equal 1, top_n[0]['key2_uniq_count']

    l.shift(5)
    top_n = l.get(10)
    assert_equal 0, top_n.length
  end

  def test_non_uniq_count
    l = UniqCount::List.new
    assert_equal [], l.get(5)

    l.add([[1, 'foo', nil], [1, 'foo', nil]])
    top_n = l.get(10)
    assert_equal 1, top_n.length
    assert_equal 0, top_n[0]['rank']
    assert_equal 'foo', top_n[0]['key1']
    assert_equal 2, top_n[0]['key2_count']
    assert_equal 1, top_n[0]['key2_uniq_count']

    l.add([[1, 'bar', nil], [2, 'bar', nil], [2, 'bar', nil]])
    top_n = l.get(10)
    assert_equal 2, top_n.length
    assert_equal 0, top_n[0]['rank']
    assert_equal 'bar', top_n[0]['key1']
    assert_equal 3, top_n[0]['key2_count']
    assert_equal 1, top_n[0]['key2_uniq_count']
    assert_equal 1, top_n[1]['rank']
    assert_equal 'foo', top_n[1]['key1']
    assert_equal 2, top_n[1]['key2_count']
    assert_equal 1, top_n[1]['key2_uniq_count']

    l.shift(1)

    l.add([[1, 'foo', nil], [3, 'foo', nil]])
    top_n = l.get(10)
    assert_equal 2, top_n.length
    assert_equal 0, top_n[0]['rank']
    assert_equal 'foo', top_n[0]['key1']
    assert_equal 4, top_n[0]['key2_count']
    assert_equal 1, top_n[0]['key2_uniq_count']
    assert_equal 1, top_n[1]['rank']
    assert_equal 'bar', top_n[1]['key1']
    assert_equal 3, top_n[1]['key2_count']
    assert_equal 1, top_n[1]['key2_uniq_count']

    l.shift(2)
    l.add([[4, 'bar', nil]])
    top_n = l.get(10)
    assert_equal 2, top_n.length
    assert_equal 0, top_n[0]['rank']
    assert_equal 'bar', top_n[0]['key1']
    assert_equal 3, top_n[0]['key2_count']
    assert_equal 1, top_n[0]['key2_uniq_count']
    assert_equal 1, top_n[1]['rank']
    assert_equal 'foo', top_n[1]['key1']
    assert_equal 1, top_n[1]['key2_count']
    assert_equal 1, top_n[1]['key2_uniq_count']

    l.shift(3)
    top_n = l.get(10)
    assert_equal 2, top_n.length

    l.shift(4)
    top_n = l.get(10)
    assert_equal 1, top_n.length
    assert_equal 0, top_n[0]['rank']
    assert_equal 'bar', top_n[0]['key1']
    assert_equal 1, top_n[0]['key2_count']
    assert_equal 1, top_n[0]['key2_uniq_count']

    l.shift(5)
    top_n = l.get(10)
    assert_equal 0, top_n.length
  end
end
