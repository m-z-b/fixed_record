

# Associate some classes with data files

class HappyPath < FixedRecord
  data File.join( __dir__, "happy_path.yml")
end

class MissingData < FixedRecord
  data File.join( __dir__, "missing_file.yml") # Does not exist
end

class MissingField < FixedRecord
  data File.join( __dir__, "missing_field.yml")
end

class ExtraField < FixedRecord
  data File.join( __dir__, "extra_field.yml")
end

class NoArray < FixedRecord
  data File.join( __dir__, "no_array.yml")
end



RSpec.describe FixedRecord do
  it "has a version number" do
    expect(FixedRecord::VERSION).not_to be nil
  end

  context "on the Happy Path" do

    it "returns the correct count" do
      expect(HappyPath.count).to be 2
    end

    it "implements each" do
      expect(HappyPath).to respond_to:(each)
    end

    it "returns the correct data for the first record" do
      expect(HappyPath.first.name).to eq "Albion Research Ltd."
      expect(HappyPath.first.url).to eq "https://www.albionresearch.com/"
    end


    it "returns the correct data for the last record" do
      expect(HappyPath.all[1].name).to eq "BBC"
      expect(HappyPath.all[1].url).to eq "https://www.bbc.co.uk/"
    end

  end

  it "raises an Errno::ENOENT exception if the data file is missing" do
    expect {
      MissingData.all
    }.to raise_error(Errno::ENOENT)
  end

  it "raises an ArgumentError exception if a record has a missing field" do
    expect {
      MissingField.all
    }.to raise_error(ArgumentError)
  end

  it "raises an ArgumentError exception if a record has an extra field" do
    expect {
      ExtraField.all
    }.to raise_error(ArgumentError)
  end

  it "raises an ArgumentError exception if there is no array in the YAML file" do
    expect {
      NoArray.all
    }.to raise_error(ArgumentError)
  end



end
