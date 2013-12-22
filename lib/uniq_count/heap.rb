# -*- coding: utf-8 -*-

module UniqCount
  class Heap
    def initialize(comparator)
      @heap = []
      @refs = {}
      @refs.compare_by_identity
      @comparator = comparator
    end

    def length
      @heap.length
    end

    def inspect
      q = []
      max_depth = @heap.length > 0 ? (Math::log(@heap.length)/Math::log(2)).floor : 0
      q << 0 if @heap.length > 0

      while i = q.shift do
        node = @heap[i]
        depth = Math::log(i+1)/Math::log(2)
        print "\n" if depth%1 == 0.0
        print node[:count].to_s + ' '
        q.concat(children_idx(i))
      end
      puts
      puts
      print @heap.inspect
    end

    def add(item)
      if @refs[item]
        raise StandardError
      end
      @heap << item
      i = @heap.length - 1
      @refs[item] = i
      adjust_parent(i)
    end

    def pop
      item = @heap.pop
      unless @refs.delete(item)
        raise StandardError
      end
      item
    end

    def update(item)
      unless i = @refs[item]
        raise StandardError
      end
      adjust_parent(i) || adjust_children(i)
    end

    def remove(item)
      unless i = @refs[item]
        raise StandardError
      end
      j = @heap.length - 1

      if i != j
        swap(i, j)
        pop
        adjust_children(i) || adjust_parent(i)
      else
        pop
      end
    end

    def pick
      return nil unless @heap.length > 0
      swap(0, @heap.length - 1)
      item = pop
      adjust_children(0)
      item
    end

    def first(n = nil)
      items = []
      (n || 1).times.each do
        if item = pick
          items << item
        end
      end
      items.each{|item| add(item) }
      n ? items : items[0]
    end

    #protected

    def adjust_parent(i)
      current = @heap[i]
      return unless j = parent_idx(i)
      parent = @heap[j]
      if @comparator[parent, current] < 0
        swap(i, j)
        adjust_parent(j)
        true
      else
        false
      end
    end

    def adjust_children(i)
      current = @heap[i]
      j, child = children_idx(i).map{|j|
        [j, @heap[j]]
      }.max{|item1, item2|
        @comparator[item1.last, item2.last]
      }

      if child && @comparator[child, current] > 0
        swap(i, j)
        adjust_children(j)
        true
      else
        false
      end
    end

    def swap(parent_idx, child_idx)
      return if parent_idx == child_idx
      parent, child = @heap[parent_idx], @heap[child_idx]
      @heap[parent_idx], @heap[child_idx] = child, parent
      @refs[parent], @refs[child] = child_idx, parent_idx
    end

    def parent_idx(i)
      i > 0 ? (i-1)/2 : nil
    end

    def children_idx(i)
      if @heap.length > 2*i+2
        [2*i+1, 2*i+2]
      elsif @heap.length > 2*i+1
        [2*i+1]
      else
        []
      end
    end
  end
end
