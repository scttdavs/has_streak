module HasStreak
  class Streak
    def initialize(instance, association)
      @instance = instance
      @association = association
    end

    def length
      determine_consecutive_days
    end

    def longest_streak
      determine_longest_streak
    end

    private

    attr_reader :association, :instance

    def days
      @days ||= instance.send(association).order("created_at DESC").pluck(:created_at).map(&:to_date).uniq
    end

    def determine_consecutive_days
      streak = first_day_in_collection_is_today? ? 1 : 0
      days.each_with_index do |day, index|
        break unless first_day_in_collection_is_today?
        if days[index+1] == day.yesterday
          streak += 1
        else
          break
        end
      end
      streak
    end

    def all_streaks
      all_days = days.clone
      return all_days if all_days.empty?

      streaks = [ [ all_days.pop ] ]

      while all_days.any?
        current_streak = streaks.last
        current_day = all_days.pop
  
        if current_streak.last.tomorrow == current_day
          current_streak.push current_day
        else
          streaks.push [current_day]
        end
      end

      streaks

    end

    def determine_longest_streak
      longest = 0

      all_streaks.each do |streak|
        longest = streak.length if streak.length > longest
      end

      longest
    end

    def first_day_in_collection_is_today?
      days.first == Date.current
    end
  end
end
