class Club < ApplicationRecord
  has_one_attached :logo

  has_many :home_matches, class_name: "Match", foreign_key: "home_team_id"
  has_many :away_matches, class_name: "Match", foreign_key: "away_team_id"
  has_many :players
  belongs_to :league

  def matches
    Match.where("home_team_id = ? OR away_team_id = ?", self.id, self.id)
  end

  def matches_on(year = nil)
    return nil unless year

    matches.where(kicked_off_at: Date.new(year, 1, 1).in_time_zone.all_year)
  end

  def won?(match)
    match.winner == self
  end

  def lost?(match)
    match.loser == self
  end

  def draw?(match)
    match.draw?
  end

  def win_on(year)
    count_num_of("won", year)
  end

  def lost_on(year)
    count_num_of("lost", year)
  end

  def draw_on(year)
    count_num_of("draw", year)
  end

  def homebase
    "#{hometown}, #{country}"
  end

  def players_average_age
    (players.sum(&:age) / players.length).to_f
  end

  private

  def count_num_of(won_lost_or_draw, year)
    year = Date.new(year, 1, 1)
    count = 0
    matches.where(kicked_off_at: year.all_year).each do |match|
      case won_lost_or_draw
      when "won" then
        count += 1 if won?(match)
      when "lost" then
        count += 1 if lost?(match)
      when "draw" then
        count += 1 if draw?(match)
      end
    end
    count
  end
end
