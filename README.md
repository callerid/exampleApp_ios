CALLERID.COM
iOS Sample Application
---------------------
spenland@callerid.com
-------------------------------------------------------------------------------

iOS Development
 - This is a tutorial on developing a simple CallerID app on iOS using Swift.
 - This app will use the 'CocoaAsyncSocket' libraries to make UDP coding easier. 

 - To test your app you can use 'Packet Sender' found at:
    https://packetsender.com
	
	Packets to be loaded and sent using Packet Sender that are in the format of CallerID.com packets can be found in this repo under 'Sample UDP Packets'

-------------------------------------------------------------------------------

1- Install cocoaPods:
	https://cocoapods.org
	
	Terminal install:
	sudo gem install cocoapods

2- Create a project using XCode.

3- Create/initalize podfile to include:
	use_frameworks!
	pod 'CocoaAsyncSocket'
	
4- In terminal CD to your project directory
    Run 'pod install' to add dependencies to your project
	
	       ***After using 'pod install'***
	Remember to open your project from now on using the
	'workspace' file instead of project file.
	***************************************************
	
5- 