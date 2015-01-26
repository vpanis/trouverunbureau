require 'rails_helper'

RSpec.describe RangeDateCollider, type: :model do

  context 'RangeDatecollisioner with 4 max permited collitions,
           granularity 30 min and ordered_and_clean in true' do

    before(:each) do
      @beginning_of_day = Time.new.at_beginning_of_day
      @rdc = RangeDateCollider.new(max_collition_permited: 4,
                                   first_date: @beginning_of_day,
                                   minute_granularity: 30)
    end

    it 'don\'t add a range if the \'from\' date it\'s invalid' do
      @rdc.add_time_range(nil, @beginning_of_day.advance(hours: 1), 1)
      expect(@rdc.valid?).to be(false)
      expect(@rdc.errors[0][:type]).to be(:invalid_entry)
    end

    it 'don\'t add a range if the \'to\' date it\'s invalid' do
      @rdc.add_time_range(@beginning_of_day, nil, 1)
      expect(@rdc.valid?).to be(false)
      expect(@rdc.errors[0][:type]).to be(:invalid_entry)
    end

    it 'don\'t add a range if the \'to\' date it\'s before the \'from\'' do
      @rdc.add_time_range(@beginning_of_day.advance(hours: 1), @beginning_of_day, 1)
      expect(@rdc.valid?).to be(false)
      expect(@rdc.errors[0][:type]).to be(:invalid_entry)
    end

    it 'don\'t add a range if the quantity it\'s smaller than 0' do
      @rdc.add_time_range(@beginning_of_day, @beginning_of_day.advance(hours: 1), 0)
      expect(@rdc.valid?).to be(false)
      expect(@rdc.errors[0][:type]).to be(:invalid_entry)
    end

    it 'don\'t add a range if the quantity it\'s greater than the max_collition_permited' do
      @rdc.add_time_range(@beginning_of_day, @beginning_of_day.advance(hours: 1), 5)
      expect(@rdc.valid?).to be(false)
      expect(@rdc.errors[0][:type]).to be(:entry_exceed_max)
    end

    it 'add a valid range' do
      @rdc.add_time_range(@beginning_of_day, @beginning_of_day.at_end_of_hour, 1)
      expect(@rdc.valid?).to be(true)
      expect(@rdc.range_array).to contain_exactly(range: (0..1), quantity: 1)
    end

    it 'add two ranges with same from' do
      @rdc.add_time_range(@beginning_of_day, @beginning_of_day.at_end_of_hour, 1)
      @rdc.add_time_range(@beginning_of_day, @beginning_of_day.at_end_of_hour.advance(hours: 1), 1)
      expect(@rdc.valid?).to be(true)
      expect(@rdc.range_array).to contain_exactly({ range: (0..1), quantity: 2 },
                                                  { range: 2..3, quantity: 1 })
    end

    it 'is invalid if exceeds the max with same 3 ranges with the same from' do
      @rdc.add_time_range(@beginning_of_day, @beginning_of_day.at_end_of_hour, 2)
      @rdc.add_time_range(@beginning_of_day, @beginning_of_day.at_end_of_hour.advance(hours: 1), 1)
      expect(@rdc.valid?).to be(true)
      expect(@rdc.range_array).to contain_exactly({ range: (0..1), quantity: 3 },
                                                  { range: 2..3, quantity: 1 })
      @rdc.add_time_range(@beginning_of_day, @beginning_of_day.at_end_of_hour, 2)
      expect(@rdc.valid?).to be(false)
      expect(@rdc.range_array).to contain_exactly({ range: (0..1), quantity: 5 },
                                                  { range: 2..3, quantity: 1 })
    end

    context 'with two ranges with same \'from\' and different \'to\' added' do
      before(:each) do
        @rdc.add_time_range(@beginning_of_day,
                            @beginning_of_day.at_end_of_hour.advance(hours: 1), 1)
        @rdc.add_time_range(@beginning_of_day,
                            @beginning_of_day.at_end_of_hour.advance(hours: 2), 1)
        expect(@rdc.valid?).to be(true)
        expect(@rdc.range_array).to contain_exactly({ range: (0..3), quantity: 2 },
                                                    { range: 4..5, quantity: 1 })
      end

      it 'add range with greater \'from\' and erases the smaller range' do
        @rdc.add_time_range(@beginning_of_day.advance(hours: 2),
                            @beginning_of_day.advance(hours: 2).at_end_of_hour, 1)
        expect(@rdc.valid?).to be(true)
        expect(@rdc.range_array).to contain_exactly(range: (4..5), quantity: 2)
      end

      it 'add range with greater \'from\' and \'to\' and erases the smaller range' do
        @rdc.add_time_range(@beginning_of_day.advance(hours: 2),
                            @beginning_of_day.advance(hours: 3).at_end_of_hour, 1)
        expect(@rdc.valid?).to be(true)
        expect(@rdc.range_array).to contain_exactly({ range: (4..5), quantity: 2 },
                                                    { range: (6..7), quantity: 1 })
      end

      it 'add range with greater \'from\' than both \'to\' and erases the smaller ranges' do
        @rdc.add_time_range(@beginning_of_day.advance(hours: 3),
                            @beginning_of_day.advance(hours: 3).at_end_of_hour, 1)
        expect(@rdc.valid?).to be(true)
        expect(@rdc.range_array).to contain_exactly(range: (6..7), quantity: 1)
      end

      it 'add range that covers 3 ranges' do
        @rdc.add_time_range(@beginning_of_day,
                            @beginning_of_day.at_end_of_hour.advance(hours: 3), 1)
        expect(@rdc.valid?).to be(true)
        expect(@rdc.range_array).to contain_exactly({ range: (0..3), quantity: 3 },
                                                    { range: 4..5, quantity: 2 },
                                                    { range: 6..7, quantity: 1 })
        @rdc.add_time_range(@beginning_of_day,
                            @beginning_of_day.at_end_of_hour.advance(hours: 4), 1)
        expect(@rdc.valid?).to be(true)
        expect(@rdc.range_array).to contain_exactly({ range: (0..3), quantity: 4 },
                                                    { range: 4..5, quantity: 3 },
                                                    { range: 6..7, quantity: 2 },
                                                    { range: 8..9, quantity: 1 })
      end

      it 'add range that covers 3 ranges but cuts the first' do
        @rdc.add_time_range(@beginning_of_day,
                            @beginning_of_day.at_end_of_hour.advance(hours: 3), 1)
        expect(@rdc.valid?).to be(true)
        expect(@rdc.range_array).to contain_exactly({ range: (0..3), quantity: 3 },
                                                    { range: 4..5, quantity: 2 },
                                                    { range: 6..7, quantity: 1 })
        @rdc.add_time_range(@beginning_of_day.advance(hours: 1),
                            @beginning_of_day.at_end_of_hour.advance(hours: 4), 1)
        expect(@rdc.valid?).to be(true)
        expect(@rdc.range_array).to contain_exactly({ range: (2..3), quantity: 4 },
                                                    { range: 4..5, quantity: 3 },
                                                    { range: 6..7, quantity: 2 },
                                                    { range: 8..9, quantity: 1 })
      end

      it 'add range that covers 3 ranges but cuts the first and exceeds the first' do
        @rdc.add_time_range(@beginning_of_day,
                            @beginning_of_day.at_end_of_hour.advance(hours: 3), 1)
        expect(@rdc.valid?).to be(true)
        expect(@rdc.range_array).to contain_exactly({ range: (0..3), quantity: 3 },
                                                    { range: 4..5, quantity: 2 },
                                                    { range: 6..7, quantity: 1 })
        @rdc.add_time_range(@beginning_of_day.advance(hours: 1),
                            @beginning_of_day.at_end_of_hour.advance(hours: 4), 2)
        expect(@rdc.valid?).to be(false)
        expect(@rdc.errors[0][:type]).to be(:collition_max_reached)
        expect(@rdc.errors[0][:from]).to eq(@beginning_of_day.advance(hours: 1))
        expect(@rdc.errors[0][:to]).to eq(@beginning_of_day.advance(minutes: 90))
        expect(@rdc.range_array).to contain_exactly({ range: (2..3), quantity: 5 },
                                                    { range: 4..5, quantity: 4 },
                                                    { range: 6..7, quantity: 3 },
                                                    { range: 8..9, quantity: 2 })
      end
    end
  end
end
