# frozen_string_literal: true

require "distribution"
require_relative "anthro/version"
require_relative "anthro/data"

module Anthro
  @reference_data_mutex = Mutex.new
  @reference_data = nil

  def self.reference_data
    return @reference_data if @reference_data

    @reference_data_mutex.synchronize do
      @reference_data ||= DATA.transform_values do |sources|
        { m: {}, f: {} }.tap do |sex_data|
          sources.each do |source, entries|
            entries.each do |sex, month, l, m, s|
              sex_key = sex == 1 ? :m : :f
              sex_data[sex_key][month.to_f] = { l: l, m: m, s: s }
            end
          end
        end
      end.freeze
    end
  end

  def self.clear_reference_data_cache!
    @reference_data_mutex.synchronize do
      @reference_data = nil
    end
  end

  private_class_method :clear_reference_data_cache!

  class Calculator
    VALID_MEASUREMENTS = DATA.keys.freeze
    VALID_SEXES = %w[male female m f].freeze
    AGE_RANGE_MONTHS = (0..240)
    DAYS_PER_MONTH = 30.4375

    attr_reader :z_score, :percentile

    def initialize(measurement_type:, sex:, value:, age_months: nil, age_days: nil)
      @measurement_type = measurement_type.to_sym
      @sex = sex[0].downcase
      @value = value.to_f
      @reference_data = Anthro.reference_data # Use module-level cached data

      raise ArgumentError, "Specify either age_months or age_days, not both" if age_months && age_days
      raise ArgumentError, "Either age_months or age_days must be provided" unless age_months || age_days

      @key_value = if age_months
                     age_months.to_f
                   else
                     age_days.to_f / DAYS_PER_MONTH
                   end

      validate_inputs
      @z_score = calculate_z_score
      @percentile = calculate_percentile
    end

    private

    def validate_inputs
      unless VALID_MEASUREMENTS.include?(@measurement_type)
        raise ArgumentError, "Invalid measurement type. Must be one of: #{VALID_MEASUREMENTS.join(", ")}"
      end
      raise ArgumentError, "Invalid sex. Must be 'male', 'female', 'm', or 'f'" unless VALID_SEXES.include?(@sex)

      unless AGE_RANGE_MONTHS.cover?(@key_value)
        raise ArgumentError, "Age must be between 0 and 240 months (0 to 7305 days)"
      end
      if @measurement_type == :bmi_for_age && @key_value < 24
        raise ArgumentError, "BMI is only valid for ages 24 months (730.5 days) and up"
      end
      if @measurement_type == :head_circumference_for_age && @key_value > 24
        raise ArgumentError, "Head circumference is only valid for ages 0 to 24 months"
      end

      return unless @value <= 0

      raise ArgumentError, "Value must be positive"
    end

    def calculate_z_score
      lms = get_lms_params
      raise "No LMS data available for #{@measurement_type}, #{@sex}, #{@key_value}" unless lms

      l = lms[:l]
      m = lms[:m]
      s = lms[:s]
      if l.zero?
        Math.log(@value / m) / s
      else
        (((@value / m)**l) - 1) / (l * s)
      end
    end

    def calculate_percentile
      z = @z_score
      return nil unless z

      Distribution::Normal.cdf(z) * 100
    end

    def get_lms_params
      data = @reference_data[@measurement_type]
      return nil unless data && data[@sex.to_sym]

      data_set = data[@sex.to_sym]
      return data_set[@key_value] if data_set[@key_value]

      keys = data_set.keys.sort
      lower_key = keys.select { |k| k <= @key_value }.last
      upper_key = keys.select { |k| k > @key_value }.first

      raise "No LMS data available for #{@measurement_type}, #{@sex}, #{@key_value}" unless lower_key && upper_key

      interpolate_lms(data_set[lower_key], data_set[upper_key], lower_key, upper_key)
    end

    def interpolate_lms(lower, upper, lower_key, upper_key)
      fraction = (@key_value - lower_key) / (upper_key - lower_key)
      {
        l: lower[:l] + (upper[:l] - lower[:l]) * fraction,
        m: lower[:m] + (upper[:m] - lower[:m]) * fraction,
        s: lower[:s] + (upper[:s] - lower[:s]) * fraction
      }
    end
  end

  def self.weight_for_age(sex:, value:, age_months: nil, age_days: nil)
    Calculator.new(measurement_type: :weight_for_age, sex: sex, age_months: age_months, age_days: age_days,
                   value: value)
  end

  def self.height_for_age(sex:, value:, age_months: nil, age_days: nil)
    Calculator.new(measurement_type: :height_for_age, sex: sex, age_months: age_months, age_days: age_days,
                   value: value)
  end

  def self.bmi_for_age(sex:, value:, age_months: nil, age_days: nil)
    Calculator.new(measurement_type: :bmi_for_age, sex: sex, age_months: age_months, age_days: age_days, value: value)
  end

  def self.head_circumference_for_age(sex:, value:, age_months: nil, age_days: nil)
    Calculator.new(measurement_type: :head_circumference_for_age, sex: sex, age_months: age_months, age_days: age_days,
                   value: value)
  end
end
