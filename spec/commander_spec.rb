
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Commander do
  
	before :each do
	  create_test_command
	end
	
	it "should allow access to all commands using #commands" do
	  commands.length.should eql(2) # our test command as well as help default
	end
	
	it "should set program information using #program" do
	  program :name, "test"
	  program :version, "1.2.3"
	  program :description, "just a test."
	  program(:name).should eql("test")
	  program(:version).should eql("1.2.3")
	  program(:description).should eql("just a test.")
	end
	
  it "should raise an error when crutial program info is not set" do
    new_command_runner '--help'
	  program :name, ''
    lambda { run! }.should raise_error(Commander::Runner::CommandError)
  end
  	
	it "should get command instances using #get_command" do
	  get_command(:test).name.should eql(:test)
	end
	
	it "should assign options" do
	  get_command(:test).options.length.should eql(2)
	end
	
	it "should invoke #when_called with arguments properly" do
	  get_command(:test).call([1, 2]).should eql("test 12")
	end
	
	it "should distinguish between switches and descriptions passed to #option" do
	  get_command(:test).options[0][:description].should eql("trace description")
	  get_command(:test).options[0][:switches].should eql(["-t", "--trace"])
	  get_command(:test).options[1][:description].should eql("verbose description")
	  get_command(:test).options[1][:switches].should eql(["--verbose"])
	  get_command(:test).option "--test"
	  get_command(:test).options[2][:description].should be_nil
	  get_command(:test).options[2][:switches].should eql(["--test"])
	end
	
	it "should locate command within arbitrary arguments passed" do
	  new_command_runner '--help', '--arbitrary', 'test'
	  command_runner.command_name_from_args.should eql(:test)
	end
	
 it "should resolve active command from global options passed" do
   new_command_runner '--help', 'test'
   command_runner.active_command.should be_instance_of(Commander::Command)
 end
 
 it "should resolve active command from invalid options passed" do
   new_command_runner '--help', 'test', '--arbitrary'
   command_runner.active_command.should be_instance_of(Commander::Command)
 end
 
 it "should raise invalid command error when the command is not found in the arguments passed"do
   new_command_runner '--help'
   lambda { command_runner.active_command }.should raise_error(Commander::Runner::InvalidCommandError)
 end
 
 it "should add options to previously created commands" do
   get_command(:test).option("--recursive") {}
   get_command(:test).options.length.should eql(3)
 end
 
 it "should call command option procs" do
   recursive = false
   get_command(:test).option("--recursive") { recursive = true }
   get_command(:test).run ['--recursive']
   recursive.should be_true
 end
 
 it "should call the #when_called proc when #run" do
   result = nil
   get_command(:test).when_called { |args| result = args.join(' ') }  
   get_command(:test).run ['--trace', 'just', 'some', 'args']
   result.should eql("just some args")
 end
 
 it "should initialize and call object when a class is passed to #when_called" do
  class HandleWhenCalled
    def arbitrary_method(*args) args.join('-') end 
  end
  get_command(:test).when_called HandleWhenCalled, :arbitrary_method
  get_command(:test).call("hello", "world").should eql("hello-world")
 end
 
 it "should call object when passed to #when_called " do
   class HandleWhenCalled 
     def arbitrary_method(*args) args.join('-') end 
   end
   get_command(:test).when_called HandleWhenCalled.new, :arbitrary_method
   get_command(:test).call("hello", "world").should eql("hello-world")
 end

end
