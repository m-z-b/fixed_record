

# Associate some classes with data files

class HappyPathArray < FixedRecord
  data File.join( __dir__, "happy_path_array.yml")
end

class MissingFieldArray < FixedRecord
  data File.join( __dir__, "missing_field_array.yml")
end

class ExtraFieldArray < FixedRecord
  data File.join( __dir__, "extra_field_array.yml")
end

class HappyPathHash < FixedRecord
  data File.join( __dir__, "happy_path_hash.yml")
end

class MissingFieldHash < FixedRecord
  data File.join( __dir__, "missing_field_hash.yml")
end

class ExtraFieldHash < FixedRecord
  data File.join( __dir__, "extra_field_hash.yml")
end


# Either Type

class CorruptFile < FixedRecord
  data File.join( __dir__, "corrupt_data.yml")
end

class MissingData < FixedRecord
  data File.join( __dir__, "missing_file.yml") # Does not exist
end



RSpec.describe FixedRecord do
  it "has a version number" do
    expect(FixedRecord::VERSION).not_to be nil
  end

  it "raises an Errno::ENOENT exception if the data file is missing" do
    expect {
      MissingData.all
    }.to raise_error(Errno::ENOENT)
  end



  it "raises an ArgumentError if there is not an array of hashes or hash of hashes in the YAML file" do
    expect {
      CorruptFile.all
    }.to raise_error(ArgumentError)
  end



  context "with Array data" do

    context "on the Happy Path" do

      it "returns the correct count" do
        expect(HappyPathArray.count).to be 2
      end

      it "implements each" do
        expect(HappyPathArray).to respond_to :each
      end

      it "returns the correct data for the first record" do
        expect(HappyPathArray.first.name).to eq "Albion Research Ltd."
        expect(HappyPathArray.first.url).to eq "https://www.albionresearch.com/"
      end


      it "returns the correct data for the last record" do
        expect(HappyPathArray.all[1].name).to eq "BBC"
        expect(HappyPathArray.all[1].url).to eq "https://www.bbc.co.uk/"
      end

    end

    context "on a Sad Path" do

      it "raises an ArgumentError exception if a record has a missing field" do
        expect {
          MissingFieldArray.all
        }.to raise_error(ArgumentError)
      end

      it "raises an ArgumentError exception if a record has an extra field" do
        expect {
          ExtraFieldArray.all
        }.to raise_error(ArgumentError)
      end


    end

  end # Array

  context "with Hash data" do

    context "on the Happy Path" do

      it "returns the correct count" do
        expect(HappyPathHash.count).to be 2
      end

      it "implements each" do
        expect(HappyPathHash).to respond_to :each
        count = 0
        HappyPathHash.each do |k,v|
          count = count + 1
        end
        expect(count).to eq 2
      end

      it 'returns the correct data for StaticPage#first' do
        expect(HappyPathHash['StaticPage#first'].title).to eq 'First Page'
        expect(HappyPathHash['StaticPage#first'].description).to eq 'Welcome to the First Page'
        expect(HappyPathHash['StaticPage#first'].key).to eq 'StaticPage#first'
      end

      it 'returns the correct data for StaticPage#last' do
        expect(HappyPathHash['StaticPage#last'].title).to eq 'Last Page'
        expect(HappyPathHash['StaticPage#last'].description).to eq 'Welcome to the Last Page'
        expect(HappyPathHash['StaticPage#last'].key).to eq 'StaticPage#last'
      end

      it "returns nil if the key is not found" do
        expect(HappyPathHash['StaticPage#missing']).to be nil
      end

    end

    context "on a Sad Path" do

      it "raises an ArgumentError exception if a record has a missing field" do
        expect {
          MissingFieldHash.all
        }.to raise_error(ArgumentError)
      end

      it "raises an ArgumentError exception if a record has an extra field" do
        expect {
          ExtraFieldHash.all
        }.to raise_error(ArgumentError)
      end


    end

  end # Array


end
