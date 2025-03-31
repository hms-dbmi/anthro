require "test_helper"

class TestReferenceData < Minitest::Test
  def setup
    Anthro.send(:clear_reference_data_cache!)
  end

  def test_reference_data_is_cached
    first_call = Anthro.reference_data.object_id
    second_call = Anthro.reference_data.object_id
    assert_equal first_call, second_call, "Reference data should be cached and return the same object"
  end

  def test_reference_data_is_frozen
    assert Anthro.reference_data.frozen?, "Reference data should be frozen"
  end

  def test_reference_data_structure
    data = Anthro.reference_data
    assert_instance_of Hash, data, "Reference data should be a Hash"

    # Test structure for each measurement type
    data.each do |measurement_type, sex_data|
      assert_includes %i[weight_for_age height_for_age bmi_for_age head_circumference_for_age], measurement_type
      assert_includes sex_data.keys, :m, "Should have male data"
      assert_includes sex_data.keys, :f, "Should have female data"

      # Test structure of sex-specific data
      sex_data.each do |sex, measurements|
        assert_instance_of Hash, measurements, "Measurements should be a Hash"
        refute_empty measurements, "Measurements should not be empty"

        # Test structure of measurement data
        measurements.each do |age, lms|
          assert_instance_of Float, age, "Age should be a Float"
          assert_instance_of Hash, lms, "LMS data should be a Hash"
          assert_includes lms.keys, :l, "Should have L parameter"
          assert_includes lms.keys, :m, "Should have M parameter"
          assert_includes lms.keys, :s, "Should have S parameter"
        end
      end
    end
  end

  def test_thread_safety
    threads = []
    results = []
    mutex = Mutex.new

    # Create multiple threads that access reference_data simultaneously
    10.times do
      threads << Thread.new do
        data = Anthro.reference_data
        mutex.synchronize { results << data.object_id }
      end
    end

    threads.each(&:join)

    # All threads should get the same object_id
    assert_equal 1, results.uniq.size, "All threads should get the same reference_data object"
  end

  def test_data_integrity
    data = Anthro.reference_data

    # Test a specific known value
    weight_male_0 = data[:weight_for_age][:m][0.0]
    assert_kind_of Hash, weight_male_0
    assert_includes weight_male_0.keys, :l
    assert_includes weight_male_0.keys, :m
    assert_includes weight_male_0.keys, :s

    # Ensure the entire structure is frozen
    assert data.frozen?, "Top level hash should be frozen"
    assert data[:weight_for_age].frozen?, "Measurement type hash should be frozen"
    assert data[:weight_for_age][:m].frozen?, "Sex-specific hash should be frozen"
    assert data[:weight_for_age][:m][0.0].frozen?, "LMS hash should be frozen"

    # Test modification at different levels
    assert_raises(FrozenError) { data[:new_key] = {} }
    assert_raises(FrozenError) { data[:weight_for_age][:new_sex] = {} }
    assert_raises(FrozenError) { data[:weight_for_age][:m][0.0] = {} }
    assert_raises(FrozenError) { data[:weight_for_age][:m][0.0][:l] = 1 }
  end

  def test_clear_reference_data_cache
    first_data = Anthro.reference_data
    Anthro.send(:clear_reference_data_cache!)
    second_data = Anthro.reference_data

    refute_equal first_data.object_id, second_data.object_id,
                 "After clearing cache, should get different object"
  end

  def test_data_consistency
    data = Anthro.reference_data

    # Test that all measurement types have consistent age ranges
    weight_ages = data[:weight_for_age][:m].keys.sort
    height_ages = data[:height_for_age][:m].keys.sort
    bmi_ages = data[:bmi_for_age][:m].keys.sort
    head_ages = data[:head_circumference_for_age][:m].keys.sort

    assert_operator weight_ages.first, :<=, 0, "Weight data should start at 0 months"
    assert_operator height_ages.first, :<=, 0, "Height data should start at 0 months"
    assert_operator bmi_ages.first, :>=, 24, "BMI data should start at 24 months"
    assert_operator head_ages.last, :<=, 24, "Head circumference data should end at 24 months"
  end
end
