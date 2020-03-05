

# Associate some classes with data files

class HappyPathArray < FixedRecord
  data File.join( __dir__, "happy_path_array.yml")
end

class MissingFieldArray < FixedRecord
  data File.join( __dir__, "missing_field_array.yml")
end

class MissingFieldArrayRequired < FixedRecord
  data File.join( __dir__, "missing_field_array.yml"), required: [ :name, :url ]
end

class MissingFieldHashRequired < FixedRecord
  data File.join( __dir__, "missing_field_array.yml"), required: [ :title, :description ]
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

class HappyPathArrayRequired < FixedRecord
  data File.join( __dir__, "happy_path_array.yml"), required: [ :name, :url ]
end

class HappyPathArrayRequiredOptional < FixedRecord
  data File.join( __dir__, "happy_path_array.yml"), required: [ :url ], optional: [ :name ]
end

class HappyPathArrayRequiredOptional1 < FixedRecord
  data File.join( __dir__, "extra_field_array.yml"), required: [ :url, :name ], optional: [ :country ]
end

class HappyPathHashRequired < FixedRecord
  data File.join( __dir__, "happy_path_hash.yml"), required: [ :title, :description ]
end

class HappyPathHashRequiredOptional < FixedRecord
  data File.join( __dir__, "happy_path_hash.yml"), required: [ :title ], optional: [ :description ]
end

class HappyPathHashRequiredOptional1 < FixedRecord
  data File.join( __dir__, "extra_field_hash.yml"), required: [ :title, :description ], optional: [ :author ]
end

class HappySingleton < FixedRecord
  data File.join( __dir__, 'singleton_data.yml' ), singleton: true
end

class HappySingletonRequired < FixedRecord
  data File.join( __dir__, 'singleton_data.yml' ), singleton: true, required: [:name, :company]
end

class HappySingletonRequiredOptional < FixedRecord
  data File.join( __dir__, 'singleton_data.yml' ), singleton: true, required: [:name], optional: [:company]
end

class SadSingletonMissingRequired < FixedRecord
  data File.join( __dir__, 'singleton_data.yml' ), singleton: true, required: [:name, :company, :title]
end



# Either Type

class CorruptFile < FixedRecord
  data File.join( __dir__, "corrupt_data.yml")
end

class MissingData < FixedRecord
  data File.join( __dir__, "missing_file.yml") # Does not exist
end

class SyntaxErrorInData < FixedRecord
  data File.join( __dir__, 'syntax_error.yml')
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

  it "raises an ArgumentError with a suitable message if the YAML file cannot be parsed" do
    begin
      SyntaxErrorInData.all
      raise "Did not report YAML syntax error in test file"
    rescue ArgumentError => e
      # With Psych and hopefully other parsers, the error message meaningful
      expect(e.message).to match(/[Ss]yntax/)
      expect(e.message).to include(SyntaxErrorInData.filename)
    end
  end


  context "with Array data" do

    context "on the Happy Path" do

      it "returns the correct count" do
        expect(HappyPathArray.count).to be 2
      end

      it "implements each" do
        expect(HappyPathArray).to respond_to :each
        count = 0
        HappyPathArray.each do |r|
          count = count + 1
        end
        expect(count).to eq 2
      end

      it "indexing operator returns nil" do
        expect(HappyPathArray['anything']).to be nil
        expect(HappyPathArray['key']).to be nil
      end

      it "has_key? returns false" do
        expect(HappyPathArray.has_key?('anything')).to be false
      end

      it "returns the correct data for the first record" do
        expect(HappyPathArray.first.name).to eq "Albion Research Ltd."
        expect(HappyPathArray.first.url).to eq "https://www.albionresearch.com/"
      end


      it "returns the correct data for the last record" do
        expect(HappyPathArray.all[1].name).to eq "BBC"
        expect(HappyPathArray.all[1].url).to eq "https://www.bbc.co.uk/"
      end

      it "loads the data with required fields" do
        expect(HappyPathArrayRequired.count).to eq 2
        expect(HappyPathArrayRequired.first.name).to eq "Albion Research Ltd."
        expect(HappyPathArrayRequired.first.url).to eq "https://www.albionresearch.com/"
      end

      it "loads the data with required and optional fields" do
        expect(HappyPathArrayRequiredOptional.count).to eq 2
        expect(HappyPathArrayRequiredOptional.first.name).to eq "Albion Research Ltd."
        expect(HappyPathArrayRequiredOptional.first.url).to eq "https://www.albionresearch.com/"
      end

      it "loads the data with optional field" do
        expect(HappyPathArrayRequiredOptional1.count).to eq 2
        expect(HappyPathArrayRequiredOptional1.first.name).to eq "Albion Research Ltd."
        expect(HappyPathArrayRequiredOptional1.first.url).to eq "https://www.albionresearch.com/"
        expect(HappyPathArrayRequiredOptional1.first.country).to be nil
      end

    end

    context "on a Sad Path" do

      it "raises an ArgumentError exception if a record has a missing field" do
        expect {
          MissingFieldArray.all
        }.to raise_error(ArgumentError)
      end

      it "raises an ArgumentError exception if a record has a missing required field" do
        expect {
          MissingFieldArrayRequired.all
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

      it "implements has_key? correctly" do
        expect(HappyPathHash.has_key?('StaticPage#first')).to be true
        expect(HappyPathHash.has_key?('StaticPage#last')).to be true
        expect(HappyPathHash.has_key?('missing')).to be false
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

      it "loads the data with required fields" do
        expect(HappyPathHashRequired.count).to eq 2
        expect(HappyPathHashRequired['StaticPage#first'].title).to eq 'First Page'
        expect(HappyPathHashRequired['StaticPage#first'].description).to eq 'Welcome to the First Page'
        expect(HappyPathHashRequired['StaticPage#first'].key).to eq 'StaticPage#first'
        expect(HappyPathHashRequired['StaticPage#last'].title).to eq 'Last Page'
        expect(HappyPathHashRequired['StaticPage#last'].description).to eq 'Welcome to the Last Page'
        expect(HappyPathHashRequired['StaticPage#last'].key).to eq 'StaticPage#last'
      end

      it "loads the data with required and optional fields" do
        expect(HappyPathHashRequiredOptional.count).to eq 2
        expect(HappyPathHashRequiredOptional['StaticPage#first'].title).to eq 'First Page'
        expect(HappyPathHashRequiredOptional['StaticPage#first'].description).to eq 'Welcome to the First Page'
        expect(HappyPathHashRequiredOptional['StaticPage#first'].key).to eq 'StaticPage#first'
        expect(HappyPathHashRequiredOptional['StaticPage#last'].title).to eq 'Last Page'
        expect(HappyPathHashRequiredOptional['StaticPage#last'].description).to eq 'Welcome to the Last Page'
        expect(HappyPathHashRequiredOptional['StaticPage#last'].key).to eq 'StaticPage#last'
      end

      it "loads the data with optional field" do
        expect(HappyPathHashRequiredOptional1.count).to eq 2
        expect(HappyPathHashRequiredOptional1['StaticPage#first'].title).to eq 'First Page'
        expect(HappyPathHashRequiredOptional1['StaticPage#first'].description).to eq 'Welcome to the First Page'
        expect(HappyPathHashRequiredOptional1['StaticPage#first'].key).to eq 'StaticPage#first'
        expect(HappyPathHashRequiredOptional1['StaticPage#first'].author).to be nil
        expect(HappyPathHashRequiredOptional1['StaticPage#last'].title).to eq 'Last Page'
        expect(HappyPathHashRequiredOptional1['StaticPage#last'].description).to eq 'Welcome to the Last Page'
        expect(HappyPathHashRequiredOptional1['StaticPage#last'].key).to eq 'StaticPage#last'
        expect(HappyPathHashRequiredOptional1['StaticPage#last'].author).to eq 'Anne Onn'
      end



    end

    context "on a Sad Path" do

      it "raises an ArgumentError exception if a record has a missing field" do
        expect {
          MissingFieldHash.all
        }.to raise_error(ArgumentError)
      end

      it "raises an ArgumentError exception if a record has a missing required field" do
        expect {
          MissingFieldHashRequired.all
        }.to raise_error(ArgumentError)
      end


      it "raises an ArgumentError exception if a record has an extra field" do
        expect {
          ExtraFieldHash.all
        }.to raise_error(ArgumentError)
      end


    end

  end # Array


  context "Singleton with default item names" do
    it "returns the correct data" do
      expect(HappySingleton['name']).to eq 'Mike Bell'
      expect(HappySingleton['company']).to eq 'Albion Research Ltd.'
    end

    it "raises an ArgumentError if the attribute is not known" do
      expect{HappySingleton['naem']}.to raise_error(ArgumentError)
    end
  end

  context "Singleton with required item names" do
    it "returns the correct data using strings" do
      expect(HappySingletonRequired['name']).to eq 'Mike Bell'
      expect(HappySingletonRequired['company']).to eq 'Albion Research Ltd.'
    end

    it "returns the correct data using symbols" do
      expect(HappySingletonRequired[:name]).to eq 'Mike Bell'
      expect(HappySingletonRequired[:company]).to eq 'Albion Research Ltd.'
    end


    it "raises an ArgumentError if the attribute is not known" do
      expect{HappySingletonRequired['naem']}.to raise_error(ArgumentError)
    end
  end

  context "Singleton with required and optional item names" do
    it "returns the correct data" do
      expect(HappySingletonRequiredOptional['name']).to eq 'Mike Bell'
      expect(HappySingletonRequiredOptional['company']).to eq 'Albion Research Ltd.'
    end

    it "raises an ArgumentError if the attribute is not known" do
      expect{HappySingletonRequiredOptional['naem']}.to raise_error(ArgumentError)
    end
  end

  context "Sad Singelton" do
        it "raises an ArgumentError if the attribute is not known" do
      expect{SadSingletonMissingRequired['naem']}.to raise_error(ArgumentError)
    end

  end

end
